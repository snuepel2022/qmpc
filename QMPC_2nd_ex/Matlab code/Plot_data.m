clear; close all; clc
iteration = 1;
x = 1:461;
xx = 1:461;

total_reward = zeros(1,iteration);
for k = 1:iteration

    input = load(strcat('PL_local_input',num2str(k-1),'.txt'), '-ascii');
    state = load(strcat('PL_local_state',num2str(k-1),'.txt'), '-ascii');
    reward = load(strcat('PL_reward',num2str(k-1),'.txt'), '-ascii');
    new_reward = zeros(length(reward),1);
    for kk = 1: length(reward)
    new_reward(kk,1) = sum( reward(kk : length(reward)) );
    end
    
    figure(1); hold on; 
    title('Input: substrate flow rate',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); plot(x, input,'r-', 'LineWidth', 1.5);
    xlabel('timestep (30min)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('F_s (L/h)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    figure(2); hold on; 
    title('Return (total cost) each timestep',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); plot(xx, new_reward,'g-', 'LineWidth', 1.5);
    xlabel('timestep (30min)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('Re',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');    
    figure(3); hold on; 
    title('State: Time',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); plot(xx, state(1,:),'b-', 'LineWidth', 1.5);
    xlabel('timestep (30min)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('t (h)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    figure(4); hold on; 
    title('State: Cell concentration',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); plot(xx, state(2,:),'b-', 'LineWidth', 1.5);
    xlabel('timestep (30min)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('X (g/L)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    figure(5); hold on; 
    title('State: Substrate concentration',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); plot(xx, state(3,:),'b-', 'LineWidth', 1.5);
    xlabel('timestep (30min)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('S (g/L)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    figure(6); hold on; 
    title('State: Penicillin concentration',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); plot(xx, state(4,:),'b-', 'LineWidth', 1.5);
    xlabel('timestep (30min)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('P (g/L)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    figure(7); hold on; 
    title('State: Reactor volume',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); plot(xx, state(5,:),'b-', 'LineWidth', 1.5);
    xlabel('timestep (30min)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('V (L)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    
    total_reward(k) = sum(reward);
end
%total_reward=sort(reshape(total_reward,1,[]));
figure(8); hold on; title('Return (total cost) each epoch',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); plot(1:length(total_reward),total_reward,'r-', 'LineWidth', 1.5);
xlabel('epoch',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
ylabel('Return',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');