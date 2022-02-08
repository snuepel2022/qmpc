clear; clc; close all;
input = load("PL_local_input0.txt",'-ascii');
figure(1); hold on; plot(input, 'r', 'LineWidth', 1.5); 
xlabel("timestep (30min)","FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans' ); 
ylabel("Input substrate flow rate (L/h)","FontSize",12,"FontWeight", 'bold',"FontName", 'Open Sans');
title("Empirical input trajectory", "FontSize",15,"FontWeight", 'bold', "FontName", 'Open Sans' );
xlim([0, 460]);
