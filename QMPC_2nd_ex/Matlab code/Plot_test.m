clear; close all; clc

t= linspace(0,1.9,500);
True_value = load('test_label.txt', '-ascii');
test_prediction = load('predicted_label.txt','-ascii');
test_example=load('test_example.txt','-ascii');
test_times = test_example(:,1);
x = sortrows([460*test_times, test_prediction, True_value]);
test_times = x(:,1);
test_prediction = x(:,2);
True_value = x(:,3);
figure(1); hold on; plot(test_times, test_prediction, 'bx' ); hold on; plot(test_times, True_value, 'rx'); alpha(.5);
xlabel('Time step (30s)',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
ylabel('Return',"FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
title('Return per Time Step',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans'); 
legend('Predicted Data','True Data',"FontSize",10,"FontWeight", 'bold',"FontName", 'Open Sans'); xlim([0 465]);
%hold on; scatter(scaled_True_value, scaled_test_prediction); 

%scaled_True_value = load('True_Values.txt','-ascii');
%scaled_test_prediction = load('test_predictions.txt','-ascii');
figure(2); hold on; scatter(True_value, test_prediction,'bo');hold on; plot(t,t); 
xlabel("True Return","FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
ylabel("Predicted Return","FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans'); 
title('True Return and Predicted Return',"FontSize",15,"FontWeight", 'bold',"FontName", 'Open Sans')
xlim([0 1]);

%figure(1); hold on; 
%hold on; plot(test_times*460,test_prediction,'bo'); 
%hold on; plot(test_times*460,True_value,'ro', 'MarkerSize',1); 
%legend('Predicted Data','True Data'); xlim([0 465]);
%xlabel('Time step'); ylabel('Normalized Return'); title('True Return and Predicted Return per Time Step'); 
%hold on; scatter(scaled_True_value, scaled_test_prediction); 

%legend('normal input','scaled input')
%figure(2); hold on; subplot(1,2,1); plot(True_value); subplot(1,2,2); plot(test_prediction);
%figure(3); hold on; scatter(True_value,scaled_True_value);
