clear; close all; clc;

k = 10; 
mm = 6;   % state number

state = load(strcat('PL_state',num2str(k-1),'.txt'), '-ascii');
input = load(strcat('PL_input',num2str(k-1),'.txt'), '-ascii');
reward = load(strcat('PL_reward',num2str(k-1),'.txt'), '-ascii');

xmin = [0, 0, 0.0001, 0, 0];
xmax = [230, 150, 25, 100, 110000];
umin = 10;
umax = 240;

local_input = input(1,:) + 5/3*input(2,:);
local_state(1,:) = state(1,:);
local_state(2,:) = sum(state(2:5,:));
local_state(3,:) = state(7,:);
local_state(4,:) = state(8,:);
local_state(5,:) = state(9,:);
ss = local_state; si = local_input;
for k = 1:length(local_state)
    ss(:,k) = ((local_state(:,k)' - xmin)./(xmax - xmin))';
    si(:,k) = ((local_input(:,k)' - umin)./(umax - umin))';
end
sc = [ss; si];

value_tra = zeros(1, length(local_state));
ell_tra = zeros(1, length(local_state));
for k = 1:length(local_state)
    value_tra(k) = nn(sc(:,k));
end

figure(1);
plot(value_tra);

%%
Xvalue_tra = zeros(101, length(local_state));
Evalue_tra = zeros(101, length(local_state));
z = 0:0.01:1;
for k = 1:floor(length(local_state)/10)
    k = 10*k + 1;
    disp(k)
    for kk = 1:101
        sc_now = sc(:,k); sc_now(mm) = z(kk);
        Xvalue_tra(kk,k) = nn(sc_now);
        %Evalue_tra(kk,k) = (sc_now - ellipse_center)'*ellipse_matrix*(sc_now - ellipse_center);
    end
    figure; hold on;
    plot(z, Xvalue_tra(:,k));  plot(sc(mm,k), value_tra(k), 'o')
    pause(1)
    close all
    %figure; hold on;
    %plot(z, Evalue_tra(:,k));  plot(sc(mm,k), ell_tra(k), 'o')
    %pause(0.1)
    %close all
    %figure; hold on;
    %plot(z, Xvalue_tra(:,k));  plot(z, Xvalue_tra(:,k) + ex_rate*Evalue_tra(:,k));  plot(sc(mm,k), value_tra(k) + ex_rate*ell_tra(k), 'o')
    %pause(0.1)
    %close all
end


