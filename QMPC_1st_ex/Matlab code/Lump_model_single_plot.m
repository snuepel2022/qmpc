close all; clear; clc;
%clear x u

tspan = [0 0.5];
horizon = 15;
iteration = 6;

%%
state = load(strcat('PE_state',num2str(iteration-1),'.txt'), '-ascii');
input = load(strcat('PE_input',num2str(iteration-1),'.txt'), '-ascii'); 
para = load(strcat('PE_para',num2str(iteration-1),'.txt'), '-ascii');
pe_flag = load(strcat('PE_flag',num2str(iteration-1),'.txt'), '-ascii');
pe_cost = load(strcat('PE_cost',num2str(iteration-1),'.txt'), '-ascii');

for k = 1:floor(460/horizon)-1
    o = state(:, horizon*(k-1)+1: horizon*(k+1) + 1);
    u = input(:, horizon*(k-1)+1: horizon*(k+1) + 1);
    x = o(:,1);
    p = para(:,horizon*k+1);

    for kk = 1:2*horizon
        [t,y] = ode15s(@(t,y) Local_model(t,y,u(:,kk),p), tspan, x(:,kk));
        x(:, kk + 1) = y(end,:);
    end

    figure(1); 
    subplot(2,2,1); hold on; plot(x(2,:), '--'); plot(o(2,:), '-'); title('X')
    subplot(2,2,2); hold on; plot(x(3,:), '--'); plot(o(3,:), '-'); title('S')
    subplot(2,2,3); hold on; plot(x(4,:), '--'); plot(o(4,:), '-'); title('P')
    subplot(2,2,4); hold on; plot(x(5,:), '--'); plot(o(5,:), '-'); title('V')
    disp(horizon*k+1)
    disp(pe_flag(:, horizon*k+1))
    disp(pe_cost(:, horizon*k+1))
    pause(2); close all
end

%%

% load('para_bound')

% figure(2);
% for k = 1:9
%     subplot(3,3,k); hold on; plot(pl(k,:),'r'); plot(pu(k,:),'r'); plot(pg(k,:),'k'); plot(para(k,1:end-1));
% end

%%
function [out] = Local_model(t, y, input, par)
% y : t, X, S, P, V
% input : F_s
% parameter : mu1, mu2, mu3, mu4, k1, k2, s_star, F_evp, s_f

dt = 0.5;
dtdt = 1;
dVdt = 0.8463*input(1) + 29.57 - par(8)*y(5);
dXdt = par(1)*y(3)*y(2)/(par(5) + y(3)) - y(2)*dVdt/y(5);
dSdt = -par(2)*y(3)*y(2)/(par(6) + y(3)) - par(3)*y(2)*exp(-1/2*((y(3) - par(7))/0.0015)^2) + input(1)*par(9)/y(5) - y(3)*dVdt/y(5);
dPdt =  par(4)*y(2)*exp(-1/2*((y(3) - par(7))/0.0015)^2) - 0.0027*y(4) - y(4)*dVdt/y(5);

out = [dtdt; dXdt; dSdt; dPdt; dVdt];
end


%%

% save('Parameter_lower_bound.txt', 'pl', '-ascii'); 
% save('Parameter_upper_bound.txt', 'pu', '-ascii');
% save('Parameter_initial_guess.txt', 'pg', '-ascii');