# 2021.06.02 written by Tae Hoon Oh, E-mail: rozenk@snu.ac.kr
# Main script to simulate the bio-reactor with QMPC
# The details are presented in the paper :
# "Integration of Reinforcement Learning and Predictive Control to Optimize Semi-batch bioreactor"

import numpy as np
import casadi as ca
import tensorflow as tf
import time
import os
import pickle

import UtilityFunctions
from critic_for_qmpc import DNN
from OptimalControl import QMPC
from PlantDynamics import PlantSimulator

TOTAL_BATCH = 1000
INITIAL_BATCH = 10
BASE_SEED = 1000
STATE_PERTURB = False
PARA_PERTURB = False
INITIAL_INPUT_PERTURB = 0.2
INITIAL_RANGE = 0.

LEARNING_PERIOD = 5
UPDATING_PERIOD = 5*LEARNING_PERIOD
LEARNING_RATE = 0.019
UPDATING_RATE = 0.01
VALIDATION_RATIO = 0.2

BUFFER_MAX = 500000
INITIAL_BUFFER_COUNT = 0
EPOCH = 300
BATCH_SIZE = 8  # Data batch size

HORIZON_LENGTH = 20
COLLOCATION_NUMBER = 3
ELEMENT_NUMBER = 1

MPC_START = 0
MPC_MAX_HORIZON = 3
MPC_HORIZON = 3
MPC_BOUND = 1.0
MPC_RELAX = 3
MPC_INPUT_PERTURB = 0.
# TRIAL_FLAG = 5
# REPEAT_FLAG = 3
# MPC_REPEAT_FLAG = 10

EXPLORATION_RATE = 0.1
EXPLORATION_RATE2 = 0.
NODE_NUMBER = [16, 4, 1]  # [4, 4, 1]
TRAIN_BOUND = 1.0

total_running_time = time.time()

np.random.seed(BASE_SEED)

# Plant set-up
plant = PlantSimulator(seed=BASE_SEED, state_perturb=STATE_PERTURB, parameter_perturb=PARA_PERTURB)


# Neural network set-up
nn_trainer = DNN(state_dim=plant.state_dimension, input_dim=plant.input_dimension, node_number=NODE_NUMBER,
                 buffer_size=BUFFER_MAX, learning_rate=LEARNING_RATE, terminal_cost=plant.terminal_cost, seed=BASE_SEED,
                 state_min=plant.xmin, state_max=plant.xmax, input_min=plant.umin, input_max=plant.umax)

error_history = []
buffer_count = 0

predict_critic = nn_trainer.build_critic()
eval_critic = nn_trainer.build_critic()
eval_critic.set_weights(predict_critic.get_weights())
#critic_optimizer = tf.keras.optimizers.Adam(learning_rate=lr_schedule)
lr_schedule = tf.keras.optimizers.schedules.ExponentialDecay(
    initial_learning_rate=LEARNING_RATE,
    decay_steps=400,
    decay_rate=0.1)
critic_optimizer = tf.keras.optimizers.Adam(lr_schedule)
#critic_optimizer = tf.keras.optimizers.Adam(LEARNING_RATE)
#critic_optimizer = tf.keras.optimizers.RMSprop(LEARNING_RATE)
#critic_optimizer = tf.keras.optimizers.Adamax(LEARNING_RATE)
#critic_optimizer = tf.keras.optimizers.Adadelta(LEARNING_RATE)
#critic_optimizer = tf.keras.optimizers.SGD(LEARNING_RATE)

# Initial NN weights
# If the initial weights are used, then please turn off the MC train below
with open('nn_train_ini.pickle', 'rb') as file:
    nn_initial_weight = pickle.load(file)
predict_critic.set_weights(nn_initial_weight)
eval_critic.set_weights(nn_initial_weight)


'''
# Historical data  
with open('nn_data.pickle', 'rb') as f:
    saved_data = pickle.load(f)
nn_trainer.state_buffer = saved_data[0]
nn_trainer.action_buffer = saved_data[1]
nn_trainer.reward_buffer = saved_data[2]
nn_trainer.next_state_buffer = saved_data[3]
'''

# Create path to save the data
directory = os.getcwd()
if not os.path.exists(directory + '/Plant data qmpc'):
    os.mkdir(directory + '/Plant data')

# Delete every file in the path
for file in os.scandir(directory + '/Plant data qmpc'):
    os.remove(file.path)

'####################### Initial batch runs ###########################'
for epi in range(INITIAL_BATCH):
    initial_batch_run_time = time.time()
    print('********** Batch number: ', epi, '************')
    # Define the plant
    plant.seed = BASE_SEED + TOTAL_BATCH + epi

    # Initial state, input, and value function
    state, _ = plant.reset()
    u = 6*np.random.random((2, 21))
    # u = 6*np.ones((2, 11))*(epi/INITIAL_BATCH)
    # u = np.array([[2.0, 10/3, 10/3, 10/3, 10/3, 10/3, 10/3, 10/3, 10/3, 10/3, 16/3],
    #              [0.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0, 6.0]])
    # u = (1+0.2*np.random.randn(1))*np.array([[1.3, 1.8, 2.0, 2.5, 4.2, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0],
    #                                          [0.0, 0.0, 0.0, 0.0, 2.0, 3.0, 2.0, 3.0, 2.0, 3.0, 2.0]])
    # u = (1+0.1*np.random.randn(1))*np.array([[1.0, 1.0, 1.0, 1.0, 1.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0],
    #                                         [0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0]])
    u = np.clip(u, 0., 6.)
    p = np.array([0.2])

    # Data record - descaled values
    PL_state_record = np.zeros((plant.state_dimension, HORIZON_LENGTH + 1))
    PL_input_record = np.zeros((plant.input_dimension, HORIZON_LENGTH + 1))
    PL_reward_record = np.zeros((1, HORIZON_LENGTH + 1))

    for time_step in range(HORIZON_LENGTH):
        PL_state_record[:, time_step] = state
        # Input schedule & perturbation
        # u[0:2, time_step] = (1 + INITIAL_RANGE*epi/INITIAL_BATCH)*u[0:2, time_step]

        next_state, current_input, reward = plant.step(state, u[:, time_step], p, terminal_flag=False)
        PL_input_record[:, time_step] = current_input
        PL_reward_record[:, time_step] = reward

        # Store the data in buffers
        counter = buffer_count % BUFFER_MAX
        data_list = [state, current_input, reward, next_state]
        nn_trainer.save_data(data_list, counter)

        # Next time step
        state = next_state
        buffer_count += 1

    # Terminal step, input is consider as 0
    PL_state_record[:, HORIZON_LENGTH] = state
    next_state, current_input, reward = plant.step(state, u[:, time_step], p, terminal_flag=True)
    PL_reward_record[:, HORIZON_LENGTH] = reward

    os.chdir(directory + '/Plant data qmpc')
    np.savetxt('PL_state' + str(epi) + '.txt',  PL_state_record, fmt='%12.8f')
    np.savetxt('PL_input' + str(epi) + '.txt',  PL_input_record, fmt='%12.8f')
    np.savetxt('PL_reward' + str(epi) + '.txt',  PL_reward_record, fmt='%12.8f')
    os.chdir(directory)

    print("********** Computation time for a single batch:", time.time() - initial_batch_run_time)

'####################### M-C learning ###########################'
'''
ini_critic = nn_trainer.build_critic()
nn_weight, mae, mse, val_mae, val_mse, eval_critic \
    = nn_trainer.train_critic_mc(critic=ini_critic, batch_number=INITIAL_BATCH, epoch=EPOCH, batch_size=BATCH_SIZE,
                                 validation_ratio=VALIDATION_RATIO, learning_rate=LEARNING_RATE)
eval_critic.set_weights(nn_weight)
predict_critic.set_weights(nn_weight)

with open('nn_train.pickle', 'wb') as f:
    pickle.dump(predict_critic.get_weights(), f, pickle.HIGHEST_PROTOCOL)
'''

u_prev = np.array([[1.3, 1.3, 1.8, 1.8, 2.0, 2.0, 2.5, 2.5, 4.2, 4.2, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0],
                   [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 3.0, 3.0, 2.0, 2.0, 3.0, 3.0, 2.0, 2.0, 3.0, 3.0, 2.0, 2.0]])

'####################### Batch runs with controller ###########################'
for epi in range(INITIAL_BATCH, TOTAL_BATCH):
    batch_run_time = time.time()
    #print('********** Batch number **********', epi)
    # Define the plant seed
    plant.seed = BASE_SEED + epi

    # Initial state, input, and value function
    state, _ = plant.reset()

    # MPC model (Differ from plant)
    def MPC_model(xd, ud, pd):
        # descaled in, descaled out
        time, x1, x2 = ca.vertsplit(xd)
        u1, u2 = ca.vertsplit(ud)
        p1 = pd  # later change

        dtdt = 1.
        # dx_1dt = -(u1 + 0.5*u1**2)*x1 + 0.5*u2*x2/(x1 + x2 + 0.1)
        # dx_2dt = u1*x1 - p1*u2*x1
        dx_1dt = -(u1 + 0.5*u1**2)*x1 + 0.5*u2  # *x2/(x1 + x2 + 0.1)
        dx_2dt = u1*x1 - 0.2*u2*x1  # p1*u2*x1

        diff_values = ca.vertcat(dtdt, dx_1dt, dx_2dt)

        return diff_values, xd, ud, pd

    # Q-function set-up
    def q_func_gen(nn_weight):
        def activation(xx):
            x_len, _ = xx.shape
            for kk in range(x_len):
                xx[kk, :] = ca.log(1 + xx[kk, :] * xx[kk, :])
                out = xx
            return out

        def q_cost(x, u):
            out = ca.vertcat(x, u)
            for k in range(int(len(nn_weight)/2)):
                out = activation(ca.transpose(ca.mtimes(ca.transpose(out), nn_weight[2*k])) + nn_weight[2*k + 1])
            return out
        return q_cost

    nn_weight = predict_critic.get_weights()
    q_cost = q_func_gen(nn_weight)

    Controller = QMPC(state_dim=plant.state_dimension, input_dim=plant.input_dimension,
                      parameter_dim=plant.para_dimension, dynamic_model=MPC_model,
                      path_wise_cost=plant.path_wise_cost, terminal_cost=plant.terminal_cost,
                      q_function=q_cost, time_step=plant.time_interval, state_min=plant.xmin, state_max=plant.xmax,
                      input_min=plant.umin, input_max=plant.umax, parameter_min=plant.pmin, parameter_max=plant.pmax,
                      polynomial_order=COLLOCATION_NUMBER, element_number=ELEMENT_NUMBER, soft_coefficient=MPC_RELAX)

    # Data record - descaled values
    PL_state_record = np.zeros((plant.state_dimension, HORIZON_LENGTH+1))
    PL_input_record = np.zeros((plant.input_dimension, HORIZON_LENGTH+1))
    PL_reward_record = np.zeros((1, HORIZON_LENGTH + 1))

    MPC_state_record = np.zeros((Controller.state_dim, HORIZON_LENGTH+1))
    MPC_input_record = np.zeros((Controller.input_dim, HORIZON_LENGTH+1))
    MPC_cost_record = np.zeros((1, HORIZON_LENGTH))
    MPC_flag_record = np.zeros((1, HORIZON_LENGTH))

    for time_step in range(HORIZON_LENGTH):
        # print('***** Batch number ***** ', epi, ' ***** Time step *****', time_step)
        PL_state_record[:, time_step] = state
        MPC_state_record[:, time_step] = state

        '####################### MODEL PREDICTIVE CONTROL ###########################'
        # Shrinking horizon
        if HORIZON_LENGTH - time_step < MPC_MAX_HORIZON + 1:
            MPC_HORIZON = HORIZON_LENGTH - time_step
            terminal = True
        else:
            MPC_HORIZON = MPC_MAX_HORIZON
            terminal = False

        if time_step > MPC_START - 1:
            # Data extraction
            MPC_s = MPC_state_record[:, time_step]
            # MPC initial input guess  # change this too later
            MPC_u_ini = u_prev[:, time_step:]

            # Control
            # def control(self, initial_state, initial_input, parameter, horizon, terminal_flag, input_bound):
            # if np.random.random(1) < EXPLORATION_RATE*(1 - epi/TOTAL_BATCH) - 0.1:
            if np.random.random(1) < EXPLORATION_RATE * (1 - epi /TOTAL_BATCH) - 0.1:
                MPC_input_record[:, time_step] = 6*np.random.random(2)

            else:
                if MPC_HORIZON == 0:
                    opt_act, opt_v = nn_trainer._q_minimization(predict_critic, UtilityFunctions.scale(MPC_s, plant.xmin, plant.xmax),
                                                                                UtilityFunctions.scale(MPC_u_ini[:, 0], plant.umin, plant.umax), MPC_BOUND)
                    MPC_input_record[:, time_step] = UtilityFunctions.descale(opt_act[:, 0], plant.umin, plant.umax)
                    MPC_cost = opt_v
                    MPC_cost_record[:, time_step] = opt_v
                else:
                    # print(MPC_s, MPC_u_ini, p, MPC_HORIZON, terminal, MPC_BOUND)
                    MPC_x_opt, MPC_u_opt, MPC_p_opt, MPC_cost, constraint_value = \
                        Controller.control(initial_state=MPC_s, initial_input=MPC_u_ini, parameter=p, horizon=MPC_HORIZON,
                                           terminal_flag=terminal, input_bound=MPC_BOUND)

                    MPC_flag = 0
                    if any(np.array(constraint_value) < -10**(-(MPC_RELAX - 0.3))):
                        MPC_flag += 1
                        print('MPC failed..................', constraint_value)
                    '''
                    while any(np.array(constraint_value) < -10**(-(MPC_RELAX - 0.3))):  # failed
                        MPC_flag +=  1
                        if MPC_flag > MPC_REPEAT_FLAG:
                            break
                        print('************* MPC fail **************, Trial: ', MPC_flag)
                        MPC_s = (1 + 0.02*(np.random.random(5) - 0.5))*MPC_s  # perturb the initial state
                        MPC_u_ini = (1 + 0.1*(np.random.random(MPC_HORIZON) - 0.5))*MPC_u_ini  # perturb the input guess
                        MPC_x_opt, MPC_u_opt, MPC_p_opt, MPC_cost, constraint_value = \
                            Controller.control(initial_state=MPC_s, initial_input=MPC_u_ini, parameter=MPC_p,
                                               step_time_interval=step_time_interval, n=MPC_HORIZON, bound=MPC_BOUND,
                                               softing=MPC_RELAX, terminal=terminal)
                        print('***** MPC Constraint value *****', min(np.array(constraint_value)))
                    '''

                    # print('********** MPC inputs', MPC_u_opt[:, 0], ' | Reference input ', MPC_u_ini[:, 0], '**************')
                    MPC_flag_record[:, time_step] = MPC_flag
                    MPC_cost_record[:, time_step] = MPC_cost
                    MPC_input_record[:, time_step] = np.clip(MPC_u_opt[:, 0]*(1 + EXPLORATION_RATE2*np.random.randn(1)), 0, 6)


                # print('***** Episode number ***** ', epi, '*** Time step ***', time_step, '*** MPC cost ***', MPC_cost)

        '####################### Plant Simulation ###########################'
        # input_with_ex = MPC_input_record[:, time_step]*(1 + np.random.randn(0, 1, 2))
        next_state, current_input, reward = plant.step(state, MPC_input_record[:, time_step], p, terminal_flag=False)
        PL_input_record[:, time_step] = current_input
        # u_prev[:, time_step] = current_input
        PL_reward_record[:, time_step] = reward

        '####################### Neural Network training ###########################'
        # store data in buffer
        counter = buffer_count % BUFFER_MAX
        data_tuple = [state, current_input, reward, next_state]
        nn_trainer.save_data(data_tuple, counter)
        buffer_count += 1

        # training the critic
        if np.mod(buffer_count, LEARNING_PERIOD) == LEARNING_PERIOD - 1:
            batch_size_now = min(BATCH_SIZE, buffer_count)
            # if np.mean(error_history) < 0.00000005:
            #     critic_optimizer = tf.keras.optimizers.Adam(0.005)  ########################
            indices = np.random.choice(max(INITIAL_BUFFER_COUNT, buffer_count), batch_size_now, replace=False)
            # print(indices)
            indices = indices % BUFFER_MAX
            # print(indices)
            predict_critic, loss = nn_trainer.train_critic(action_bound=TRAIN_BOUND, predict_critic=predict_critic,
                                                           eval_critic=eval_critic, critic_optimizer=critic_optimizer,
                                                           batch_size_now=batch_size_now, indices=indices)
            error_history.append(loss)

        if np.mod(buffer_count, UPDATING_PERIOD) == UPDATING_PERIOD - 1:
            pw = predict_critic.get_weights()
            ew = eval_critic.get_weights()
            for k in range(len(pw)):  # layer * 2
                ew[k] = (1 - UPDATING_RATE) * ew[k] + UPDATING_RATE * pw[k]
            eval_critic.set_weights(ew)

        # Move to next time step
        state = next_state

    # Terminal step, input is consider as 0
    PL_state_record[:, HORIZON_LENGTH] = state
    MPC_state_record[:, HORIZON_LENGTH] = state
    next_state, current_input, reward = plant.step(state, np.zeros(plant.input_dimension), p, terminal_flag=True)
    PL_reward_record[:, HORIZON_LENGTH] = reward
    print(f"***** Batch number : {epi} ***** Cost : {reward}")

    '####################### M-C learning ###########################'
    '''
    if np.mod(epi, CORRECTING_PERIOD) == CORRECTING_PERIOD - 1:
        reg_critic = nn_trainer.build_critic2(LEARNING_RATE)
        reg_critic.set_weights(eval_critic.get_weights())
        nn_weight, mae, mse, val_mae, val_mse, _ \
            = nn_trainer.train_critic_mc(critic=reg_critic, batch_number=epi, epoch=EPOCH, batch_size=BATCH_SIZE)
        rw = reg_critic.get_weights()
        ew = eval_critic.get_weights()
        for k in range(2*4):  # layer * 2
            ew[k] = (1 - CORRECTING_RATE)*ew[k] + CORRECTING_RATE*rw[k]
        eval_critic.set_weights(ew)
    '''

    print("********** Computation time for a single batch:", time.time() - batch_run_time)

    # Save the data
    os.chdir(directory + '/Plant data qmpc')
    # np.savetxt('train_mae.txt', mae, fmt='%12.8f')
    # np.savetxt('valid_mae.txt', val_mae, fmt='%12.8f')
    np.savetxt('loss_mse.txt', np.array(error_history), fmt='%12.8f')
    np.savetxt('PL_state' + str(epi) + '.txt',  PL_state_record, fmt='%12.8f')
    np.savetxt('PL_input' + str(epi) + '.txt',  PL_input_record, fmt='%12.8f')
    np.savetxt('PL_reward' + str(epi) + '.txt',  PL_reward_record, fmt='%12.8f')
    np.savetxt('MPC_state' + str(epi) + '.txt', MPC_state_record, fmt='%12.8f')
    np.savetxt('MPC_input' + str(epi) + '.txt', MPC_input_record, fmt='%12.8f')
    np.savetxt('MPC_cost' + str(epi) + '.txt',  MPC_cost_record, fmt='%12.8f')
    np.savetxt('MPC_flag' + str(epi) + '.txt',  MPC_flag_record, fmt='%12.8f')
    os.chdir(directory)
    with open('nn_train.pickle', 'wb') as f:
        pickle.dump(predict_critic.get_weights(), f, pickle.HIGHEST_PROTOCOL)


save_data = [nn_trainer.state_buffer, nn_trainer.action_buffer, nn_trainer.reward_buffer,
               nn_trainer.next_state_buffer]

with open('nn_data.pickle', 'wb') as f:
    pickle.dump(save_data, f, pickle.HIGHEST_PROTOCOL)

print("********** Computation time for total batches:", time.time() - total_running_time)




