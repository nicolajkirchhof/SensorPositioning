function draw( input, solution )
%DRAW Summary of this function goes here
%   Detailed explanation goes he        %%
fsize = [325 420];
pos = [0 0];
figure;
Discretization.draw(input.discretization, input.environment);
hold on;
Discretization.draw_wpn_max_qualities(solution.discretization, solution.quality);
Discretization.draw_vfos(input.discretization, solution);
allqvall = cell2mat(input.quality.wss.val);
title(sprintf('Num SP %d, Sel SP %d, Num WPN %d\n MinQ %.4g, MaxQ %.4g,\n Mean/dQ %.4g %.4g SumQ %.4g ',...
    input.discretization.num_sensors, input.discretization.num_sensors, input.discretization.num_positions,...
    min(allqvall), max(allqvall), mean(allqvall), median(allqvall), sum(allqvall)));
set(gcf, 'Position', [pos fsize]);
axis equal;
ylim([0 8000]);
xlim([0 5500]);
pos(1) = pos(1)+325;
if pos(1) > 1590
    pos = [0 500];
end

end

