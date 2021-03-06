function out = MC_NN(s, a)
% input SA, output Return
% x <- 6x1: [state;input];
% s <- 5x1: state
% a <- 1x1: action 
cd 460Data
x = [s;a];
weight_0 = load(strcat('weight0.txt'), '-ascii');
bias_0 = load(strcat('bias0.txt'), '-ascii');
weight_1 = load(strcat('weight1.txt'), '-ascii');
bias_1 = load(strcat('bias1.txt'), '-ascii');
weight_2 = load(strcat('weight2.txt'), '-ascii');
bias_2 = load(strcat('bias2.txt'), '-ascii');
weight_3 = load(strcat('weight3.txt'), '-ascii');
bias_3 = load(strcat('bias3.txt'), '-ascii');
weight_4 = load(strcat('weight4.txt'), '-ascii');
bias_4 = load(strcat('bias4.txt'), '-ascii');


out=(x.' * weight_0).' + bias_0 ; %(inputT * w)T + b
out=arrayfun(@(x) swish(x) , out); % 를 ReLu에 삽입
out=(out.' * weight_1).' + bias_1 ;
out=arrayfun(@(x) swish(x) , out);
out=(out.' * weight_2).' + bias_2 ;
out=arrayfun(@(x) swish(x) , out);
out=(out.' * weight_3).' + bias_3 ;
out=arrayfun(@(x) swish(x) , out);
out=(out.' * weight_4).' + bias_4 ;

cd ../

%function out = relu(x)
%if x > 0
%    out = x;
%else
%    out = 0;
%end
%end

end
%function out = swish(x)
%for kk = length(x)
%    x(kk)= x(kk) / (1+exp(-x(kk)));
%end
%out = x;
%    
%end
