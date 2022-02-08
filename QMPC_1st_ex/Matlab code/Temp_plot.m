% Temp_plot
% 0.2806 - mpc/ perfect model 
% 0.3442 - mpc/ wrong model

clear; close all; format compact; clc;
iter = 100;
loss = load('loss_mse.txt');
loss_avg = loss; 
reward = zeros(1, iter);
input = load(strcat('PL_input', num2str(iter-1), '.txt'),'-ascii');
for k = 1:iter
    data = load(strcat('PL_reward', num2str(k-1), '.txt'),'-ascii');
    reward(k) = sum(data);
end
mean_reward = mean(reward)

for k = 1:length(loss)
    loss_avg(k) = mean(loss(1:k));
end

figure; hold on;
plot(loss(round(length(loss)*0.5):end))
plot(smooth(loss(round(length(loss)*0.5):end), 50), 'linewidth', 2)

figure;
plot(loss_avg); title('loss avg')

figure
plot(reward, ':', 'linewidth', 2)
hold on
plot(smooth(reward, 50), 'linewidth', 2)
plot(0.3442*ones(1,length(reward)), 'k:', 'linewidth', 2)
plot(0.2806*ones(1,length(reward)), 'k:', 'linewidth', 2)

figure; hold on;
plot(input(1,1:20), 'linewidth', 2);
plot(input(2,1:20), 'linewidth', 2);