clear; clc; close all;

Train_mae = load('train_mae.txt', '-ascii');
Train_mse = load('train_mse.txt','-ascii');
Val_mae = load('val_mae.txt', '-ascii');
Val_mse = load('val_mse.txt','-ascii');
figure(1); hold on; plot(Train_mae, 'r-', 'LineWidth', 1.5);  plot(Val_mae, 'b-', 'LineWidth', 1.5); 
legend('Train mae','Val mae',"FontSize", 12,"FontWeight", 'bold',"FontName", 'Open Sans')
title('Mae',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); 
xlabel('Epoch',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('Error',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
    
figure(2); hold on; plot(Train_mse, 'r-', 'LineWidth', 1.5);  plot(Val_mse, 'b-', 'LineWidth', 1.5); 
legend('Train mse','Val mse',"FontSize", 12,"FontWeight", 'bold',"FontName", 'Open Sans')
title('Mse',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); 
xlabel('Epoch',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
    ylabel('Error',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');