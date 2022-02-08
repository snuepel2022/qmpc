clear; clc; close all;
iteration = 20;
aa=zeros(iteration,1);
kk=[1,2,3,4,5];
first_input = load('PL_local_input0.txt','-ascii');
first_local_state = load('PL_local_state0.txt','-ascii');
first_PE = first_local_state(4,:) .* first_local_state(5,:);
first_return = 7.5761;
for k=1:iteration
    PL_state = load(strcat('PL_epi_state',num2str(k-1),'.txt'), '-ascii');
    PL_input = load(strcat('PL_epi_input',num2str(k-1),'.txt'), '-ascii');
    PL_reward = load(strcat('PL_epi_reward',num2str(k-1),'.txt'), '-ascii');
    PE_state = load(strcat('PE_state',num2str(k-1),'.txt'), '-ascii');
    PE_input = load(strcat('PE_input',num2str(k-1),'.txt'), '-ascii');
    PE_para = load(strcat('PE_para',num2str(k-1),'.txt'), '-ascii');
    PE_cost = load(strcat('PE_cost',num2str(k-1),'.txt'), '-ascii');
    PE_flag = load(strcat('PE_flag',num2str(k-1),'.txt'), '-ascii');
    PE = PE_state(4,:) .* PE_state(5,:); 
    figure(1); hold on; plot(PE_input);
    
    aa(k)=sum(PL_reward);
end
aaa = [first_return;aa];
% reward plot
figure(2); hold on; plot(0:iteration, aaa, 'r-', 'LineWidth',2);
title('Return each episode',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    xlabel('Episode',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('Re',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    xlim([0 iteration])
    
% input plot
figure(3); hold on; plot(first_input, '--r', 'LineWidth', 1.5);
hold on; plot(PE_input(1:460),'-r','LineWidth', 1.5);
xlim([0 460]); 
xlabel('Timestep (30min)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('F_s (L/h)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    legend('Empirical Input','Improved input',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    title('Empirical input and optimal input',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); 
% penicilin plot
figure(4); hold on; plot(first_PE(1:460), '--b', 'LineWidth', 1.5);
    hold on; plot(PE(1:460),'-b','LineWidth', 1.5);
    xlabel('Timestep (30min)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('Penicillin (g)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    legend('Empirical input','Improved input',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    title('Production of Penicillin',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    xlim([0 460])
    
