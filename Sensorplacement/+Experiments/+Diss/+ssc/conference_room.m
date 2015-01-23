%%
cplex = 'C:\Users\Nick\App\Cplex\cplex\bin\x64_win64\cplex.exe';

%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0:10:50;
num_wpns = 0:10:500;
num_sps =  0:10:500;

% gco = cell(numel(num_sps), numel(num_wpns));
for id_wpn = 1:numel(num_wpns)
    for id_sp = 1:numel(num_sps)
        num_wpn = num_wpns(id_wpn);
        num_sp = num_sps(id_sp);
        
        %%
        num_wpn = 250;
        num_sp = 250;
        
        input = Experiments.Diss.conference_room(num_sp, num_wpn);% true);
        %%%
        input.config.optimization = Configurations.Optimization.Discrete.ssc;
        %         output_filename = sprintf('tmp/conference_room/ssc/ssc__%d_%d_%d.mat', input.discretization.num_sensors, input.discretization.num_positions, input.discretization.num_comb);
        input.filename = Optimization.Discrete.Models.ssc(input.discretization, input.quality, input.config.optimization);
        %         save(output_filename, 'input');
        stn(input.filename);
        %% TEST solving with and without two sensors per wp
        
    end
end

%%
num_wpn = 0;
num_sp = 0;

ssc = Experiments.Diss.conference_room(num_sp, num_wpn);
ssc.config.optimization = Configurations.Optimization.Discrete.ssc;
% ssc_ind.config.optimization.type = 'ssc';
ssc.filename = Optimization.Discrete.Models.ssc(ssc.discretization, ssc.quality, ssc.config.optimization);
[ssc.solfile, ssc.logfile] = Optimization.Discrete.Solver.cplex.start(ssc.filename, cplex);
ssc.log = Optimization.Discrete.Solver.cplex.read_log(ssc.logfile);
ssc.solution = Optimization.Discrete.Solver.cplex.read_solution(ssc.solfile);
% [ssc.solution.discretization, ssc.solution.quality] = Evaluation.filter(ssc.solution, ssc.discretization, ssc.config.quality);
% ssc.solution.discretization.wpn_qualities_max = cellfun(@max, ssc.solution.quality.wss.val );


%%
fsize = [325 420];
pos = [0 0];
input = ssc_ind;
% input = ssc;
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