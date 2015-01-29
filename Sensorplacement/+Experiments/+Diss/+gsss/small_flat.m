%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0;
% num_sps =  0:10:100;
% cplex = 'C:\Users\Nick\App\Cplex\cplex\bin\x64_win64\cplex.exe';
cplex = [getenv('home') 'App\Cplex\cplex\bin\x64_win64\cplex.exe'];

%%%
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
        
        
        output_filename = sprintf('tmp/small_flat/gsss/gsss__%d_%d.mat', num_sp, num_wpn);
        if exist(output_filename, 'file')> 0
            continue
        end
        
        %%
%         num_wpn = 10;
%         num_sp = 0;
        
        
        input = Experiments.Diss.small_flat(num_sp, num_wpn);% true);
        %%%

%         input.config.optimization = Configurations.Optimization.Discrete.gsss;
        input.config.optimization.name = input.name;
        
%         solution_coverage = Optimization.Discrete.Greedy.gssc(input.discretization);
        %%%
%         input.solution_coverage = solution_coverage;
        gen = Configurations.Common.generic();
        gen.workdir = 'tmp/small_flat/gsss';
        ssc_config = Configurations.Optimization.Discrete.ssc(gen);
        ssc.filename = Optimization.Discrete.Models.ssc(input.discretization, [], ssc_config);
        [ssc.solfile, ssc.logfile] = Optimization.Discrete.Solver.cplex.start(ssc.filename, cplex, false);
        ssc.solution_coverage = Optimization.Discrete.Solver.cplex.read_solution(ssc.solfile);
        ssc.solution_coverage.log = Optimization.Discrete.Solver.cplex.read_log(ssc.logfile);
        ssc.solution_coverage.ssc = ssc;
        
        ssc.config.optimization = Configurations.Optimization.Discrete.gsss;
        ssc.solution = Optimization.Discrete.Greedy.gsss(input.discretization, input.quality, ssc.solution_coverage, ssc.config.optimization);
        [ssc.solution.discretization, ssc.solution.quality] = Evaluation.filter(ssc.solution, input.discretization, input.config.discretization);
        %%
        input = ssc;
        input.num_sp = num_sp;
        input.num_wpn = num_wpn;
       
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
write_log([], '#on');
input.solution = ssc.solution;
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