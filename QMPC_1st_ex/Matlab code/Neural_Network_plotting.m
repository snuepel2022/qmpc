% plot Reward w.r.t. change of input (5개 고정, 1개 변화)

clear; clc; close all;
t = 1;

while t < 11

cd 361Data
input = load('SA_input.txt','-ascii');
input = input.'; % 6 * data #
cd ../
    h = randi(length(input),1);
    i = input(:,h);
    s = i(1:5);
    a = i(6);
    
for k=1:20  %   k=1:length(input) % for all input, calculating
    %   x = input(:,k);
    % [시간, 세포농도, 기질 양, 생성 페니실린 양, 반응기 부피]
    
    for kk = 1:5
    s = i(1:5);
    a = i(6);
    %s = [0.804347830000000;0.226574520000000;4.34600000000000e-05;0.513451780000000;0.571189510000000];
    %a = [0.710164410000000];
    if kk == 3
        s(kk) = s(kk) + 0.001*0.0001*k;
    else
    s(kk) = s(kk) + 0.001*k;
    end
  
    x= MC_NN(s, a);
    xx(kk,k) = s(kk);
    yy(kk,k) = x;
    end
    s = i(1:5);
    a = i(6);
    a = a + 0.001*k;
    x= MC_NN(s, a);
    xx(6,k) = a;
    yy(6,k) = x;
    
end


figure(t); hold on; 
subplot(3,2,1); hold on; plot(xx(1,:),yy(1,:)); xlabel("Time"); ylabel("Return");title("Time as variable");
subplot(3,2,2); hold on; plot(xx(2,:),yy(2,:)); xlabel("Cell concentration"); ylabel("Return");title("Cell concentration as variable");
subplot(3,2,3); hold on; plot(xx(3,:),yy(3,:)); xlabel("Substrate concentration"); ylabel("Return");title("Substrate concentration as variable");
subplot(3,2,4); hold on; plot(xx(4,:),yy(4,:)); xlabel("Product concentration"); ylabel("Return");title("Product concentration as variable");
subplot(3,2,5); hold on; plot(xx(5,:),yy(5,:)); xlabel("Reactor volume"); ylabel("Return");title("Reactor volume as variable");
subplot(3,2,6); hold on; plot(xx(6,:),yy(6,:)); xlabel("Action"); ylabel("Return");title("Action as variable");

t = t + 1; 
end
%cd ../
% layers
%x=[1;2;3;4;5;6];
%w=[1,0;3,0;5,0;0,0;0,1;1,1];
%b=[0;1];
%t= linspace(0,1,500);
%y = (predicted_python_reward-predicted_reward); 
%fprintf('Mean of all absolute errors : %d  \n',mean(abs(y)))
%figure(2); hold on; scatter(predicted_python_reward, predicted_reward);hold on;plot(t,t); xlabel("Python"); ylabel("Matlab"); title('Scatter plot of Python and Matlab')