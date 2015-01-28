%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0;
% num_sps =  0:10:100;
num_wpns = 0:10:500;
num_sps =  0:10:500;

iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps);
write_log([], '#off');
% gco = cell(numel(num_sps), numel(num_wpns));
for id_wpn = 1:numel(num_wpns)
    for id_sp = 1:numel(num_sps)
        num_wpn = num_wpns(id_wpn);
        num_sp = num_sps(id_sp);
        
        %%
%         num_wpn = 200;
%         num_sp = 500;
        
        input = Experiments.Diss.small_flat(num_sp, num_wpn);% true);
        %%%
        input.config.optimization.name = input.name;
        gcss_config = Configurations.Optimization.Discrete.gcss;
        
        gcss.config.optimization = Configurations.Optimization.Discrete.gcss;
        gcss.solution = Optimization.Discrete.Greedy.gcss(input.discretization, input.quality, gcss.config.optimization);
        [gcss.solution.discretization, gcss.solution.quality] = Evaluation.filter(gcss.solution, input.discretization, input.config.discretization);
        %%
        input = gcss;
        input.num_sp = num_sp;
        input.num_wpn = num_wpn;
        output_filename = sprintf('tmp/small_flat/gcss/gcss__%d_%d.mat', num_sp, num_wpn);
        save(output_filename, 'input');
        iteration = iteration + 1;
        if toc(tme)>next
            fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
            next = toc(tme)+stp;
        end
        
    end
end

return;
%%
input.solution = gcss.solution;
fsize = [325 420];
pos = [0 0];
% figure;
cla;
Discretization.draw(input.discretization, input.environment);
hold on;
Discretization.draw_wpn_max_qualities(input.solution.discretization, input.solution.quality);
Discretization.draw_vfos(input.discretization, input.solution);
allqval = cell2mat(input.solution.quality.wss.val);
wpnqval = cellfun(@max, input.solution.quality.wss.val);
title(sprintf('Num SP %d, Sel SP %d, Num WPN %d\n MinQ %.4g, MaxQ %.4g,\n Mean/dQ %.4g %.4g SumQ %.4g ',...
    input.discretization.num_sensors, input.solution.discretization.num_sensors, input.discretization.num_positions,...
    min(wpnqval), max(wpnqval), mean(allqval), median(wpnqval), sum(wpnqval)));
% set(gcf, 'Position', [pos fsize]);
ylim([0 9500]);
xlim([0 6500]);
% pos(1) = pos(1)+325;
% if pos(1) > 1590
%     pos = [0 500];
% end

%     end
% end
