clear; close all; clc

t= linspace(2,5,500);
True_value = load('first_true.txt', '-ascii');
test_prediction = load('first_prediction.txt','-ascii');
test_times=load('first_time.txt','-ascii');
%scaled_True_value = load('True_Values.txt','-ascii');
%scaled_test_prediction = load('test_predictions.txt','-ascii');
figure(2); hold on; scatter(True_value, test_prediction);hold on; plot(t,t); xlabel("True Normalized Return"); ylabel("Predicted Normil Return"); title('Scatter plot of True Return and Predicted Return')
figure(1); hold on; plot(test_times*460,True_value,'o'); 
hold on; plot(test_times*460, test_prediction,'x'); legend('true','predict'); xlim([0 465]);
xlabel('Time step'); ylabel('Normalized Return'); title('True Return and Predicted Return per Time Step'); 
%hold on; scatter(scaled_True_value, scaled_test_prediction); 

%legend('normal input','scaled input')
%figure(2); hold on; subplot(1,2,1); plot(True_value); subplot(1,2,2); plot(test_prediction);
%figure(3); hold on; scatter(True_value,scaled_True_value);
