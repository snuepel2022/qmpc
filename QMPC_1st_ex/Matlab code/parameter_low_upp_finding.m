fl
num = 1;
range = 459;

pl = load('Parameter_lower_bound.txt','-ascii');
pu = load('Parameter_upper_bound.txt','-ascii');
plol = load('Parameter_lower_bound_on_line.txt','-ascii');
puol = load('Parameter_upper_bound_on_line.txt','-ascii');
pg = load('Parameter_guess.txt','-ascii');

for k = 1:9
    figure(k); hold on;
    plot(pl(k,:), 'k')
    plot(pu(k,:), 'k')
    plot(plol(k,:))
    plot(puol(k,:))
end

%% Change the parameters %% check the name of saving 
pl = load('Parameter_lower_bound.txt','-ascii');
pu = load('Parameter_upper_bound.txt','-ascii');
pg = load('Parameter_guess.txt','-ascii');

ppl = pl; ppg = pg; ppu = pu;

ppu(1, num:num+range) = 0.5;
ppu(2, num:num+range) = 0.8;
ppu(3, num:num+range) = 0.06;
ppu(4, num:num+range) = 0.04;
ppu(5, num:num+range) = 1.0;
ppu(6, num:num+range) = 1.0;
ppu(7, num:num+range) = 0.004;
ppu(8, num:num+range) = 0.002;
ppu(9, num:num+range) = 640;

ppl(1, num:num+range) = 0.001;
ppl(2, num:num+range) = 0.001;
ppl(3, num:num+range) =  0.0;
ppl(4, num:num+range) =  0.0;
ppl(5, num:num+range) =  0.00005;
ppl(6, num:num+range) =  0.0002;
ppl(7, num:num+range) =  0.0015;
ppl(8, num:num+range) =  0.0001;
ppl(9, num:num+range) =  560;

save('Parameter_lower_bound_on_line.txt', 'ppl', '-ascii')
save('Parameter_upper_bound_on_line.txt', 'ppu', '-ascii')
save('Parameter_guess.txt', 'ppg', '-ascii')

