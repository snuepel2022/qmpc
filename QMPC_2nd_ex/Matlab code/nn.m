function out = nn(x)

nn_weight1 = load('nn_weight1.txt', '-ascii');
nn_weight2 = load('nn_weight2.txt', '-ascii');
nn_weight3 = load('nn_weight3.txt', '-ascii');
nn_weight4 = load('nn_weight4.txt', '-ascii');

nn_bias1 = load('nn_bias1.txt', '-ascii');
nn_bias2 = load('nn_bias2.txt', '-ascii');
nn_bias3 = load('nn_bias3.txt', '-ascii');
nn_bias4 = load('nn_bias4.txt', '-ascii');


out1 = log(1 + (nn_weight1'*x + nn_bias1).^2);
out2 = log(1 + (nn_weight2'*out1 + nn_bias2).^2);
out3 = log(1 + (nn_weight3'*out2 + nn_bias3).^2);
out4 = log(1 + (nn_weight4'*out3 + nn_bias4).^2);

out = out4;

end

