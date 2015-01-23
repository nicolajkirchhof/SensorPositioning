%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0:10:50;
num_wpns = 0:10:490;
num_sps =  0:10:500;
cplex = 'C:\Users\Nick\App\Cplex\cplex\bin\x64_win64\cplex.exe';

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
%         num_wpn = 0;
%         num_sp = 0;
        
        input = Experiments.Diss.conference_room(num_sp, num_wpn);
        stcm.config.optimization = Configurations.Optimization.Discrete.stcm;
        % stcm_ind.config.optimization.type = 'stcm';
        stcm.filename = Optimization.Discrete.Models.stcm(input.discretization, input.quality, stcm.config.optimization);
        %         stn(stcm.filename);
        [stcm.solfile, stcm.logfile] = Optimization.Discrete.Solver.cplex.start(stcm.filename, cplex, false);
        stcm.solution = Optimization.Discrete.Solver.cplex.read_solution(stcm.solfile);
        log = Optimization.Discrete.Solver.cplex.read_log(stcm.logfile);
        [stcm.solution.discretization, stcm.solution.quality] = Evaluation.filter(stcm.solution, input.discretization, input.config.quality);
        stcm.solution.discretization.wpn_qualities_max = cellfun(@max, stcm.solution.quality.wss.val );
        %%%
        for fn = fieldnames(log)'
            field = fn{1};
            stcm.solution.(field) = log.(field);
            
        end
        
        %%%
        input = stcm;
        input.num_sp = num_sp;
        input.num_wpn = num_wpn;
        output_filename = sprintf('tmp/conference_room/stcm/stcm__%d_%d.mat', num_sp, num_wpn);
        save(output_filename, 'input');
        %%
        iteration = iteration + 1;
        if toc(tme)>next
            fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
            next = toc(tme)+stp;
        end
    end
end

return;
%%
num_wpn = 250;
num_sp = 250;

stcm = Experiments.Diss.conference_room(num_sp, num_wpn);
stcm.config.optimization = Configurations.Optimization.Discrete.stcm;
% stcm_ind.config.optimization.type = 'stcm';
stcm.filename = Optimization.Discrete.Models.stcm(stcm.discretization, stcm.quality, stcm.config.optimization);
stn(stcm.filename);
[stcm.solfile, stcm.logfile] = Optimization.Discrete.Solver.cplex.start(stcm.filename, cplex);
stcm.log = Optimization.Discrete.Solver.cplex.read_log(stcm.logfile);
stcm.solution = Optimization.Discrete.Solver.cplex.read_solution(stcm.solfile);
[stcm.solution.discretization, stcm.solution.quality] = Evaluation.filter(stcm.solution, stcm.discretization, stcm.config.quality);
stcm.solution.discretization.wpn_qualities_max = cellfun(@max, stcm.solution.quality.wss.val );


%%
fsize = [325 420];
pos = [0 0];
input = stcm;
figure;
Discretization.draw(input.discretization, input.environment);
hold on;
Discretization.draw_wpn_max_qualities(input.solution.discretization, input.solution.quality);
Discretization.draw_vfos(input.discretization, input.solution);
allqvall = cell2mat(input.solution.quality.wss.val);
title(sprintf('Num SP %d, Sel SP %d, Num WPN %d\n MinQ %.4g, MaxQ %.4g,\n Mean/dQ %.4g %.4g SumQ %.4g ',...
    input.discretization.num_sensors, input.solution.discretization.num_sensors, input.discretization.num_positions,...
    min(allqvall), max(allqvall), mean(allqvall), median(allqvall), sum(allqvall)));
set(gcf, 'Position', [pos fsize]);
pos(1) = pos(1)+325;
if pos(1) > 1590
    pos = [0 500];
end