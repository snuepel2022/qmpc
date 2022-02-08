clear; clc; close all;
data = load('apprx_real_data_at_epi_1_ts_400_var_0.100000.txt','-ascii');
time_var_data = data(1:20, :);
cell_conc_var_data = data(21:40, :);
subs_conc_var_data = data(41:60, :);
peni_conc_var_data = data(61:80, :);
v_var_data = data(81:100, :);
input_var_data = data(101:120, :);

figure(1); hold on; title("apprx_real_data_at_epi_1_ts_1_var_0.010000.txt"); 
subplot(2,3,1); hold on; plot(time_var_data(:,1), time_var_data(:,7),'r-', 'LineWidth', 1.5); hold on; plot(time_var_data(:,1), time_var_data(:,8),'bo');
xlabel("Time"); ylabel("Reward"); title("Time"); legend("NN","Approximation")
subplot(2,3,2); hold on; plot(cell_conc_var_data(:,2), cell_conc_var_data(:,7),'r-', 'LineWidth', 1.5); hold on; plot(cell_conc_var_data(:,2), cell_conc_var_data(:,8),'bo');
xlabel("Cell"); ylabel("Reward"); title("Cell"); legend("NN","Approximation")
subplot(2,3,3); hold on; plot(subs_conc_var_data(:,3), subs_conc_var_data(:,7),'r-', 'LineWidth', 1.5); hold on; plot(subs_conc_var_data(:,3), subs_conc_var_data(:,8),'bo');
xlabel("S"); ylabel("Reward"); title("S"); legend("NN","Approximation")
subplot(2,3,4); hold on; plot(peni_conc_var_data(:,4), peni_conc_var_data(:,7),'r-', 'LineWidth', 1.5); hold on; plot(peni_conc_var_data(:,4), peni_conc_var_data(:,8),'bo');
xlabel("P"); ylabel("Reward"); title("P"); legend("NN","Approximation")
subplot(2,3,5); hold on; plot(v_var_data(:,5), v_var_data(:,7),'r-', 'LineWidth', 1.5); hold on; plot(v_var_data(:,5), v_var_data(:,8),'bo');
xlabel("V"); ylabel("Reward"); title("V"); legend("NN","Approximation")
subplot(2,3,6); hold on; plot(input_var_data(:,6), input_var_data(:,7),'r-', 'LineWidth', 1.5); hold on; plot(input_var_data(:,6),input_var_data(:,8),'bo');
xlabel("Input"); ylabel("Reward"); title("Input"); legend("NN","Approximation")