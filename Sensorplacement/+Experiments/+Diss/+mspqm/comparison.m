%%
cplex = 'C:\Users\Nick\App\Cplex\cplex\bin\x64_win64\cplex.exe'

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
        num_wpn = 0;
        num_sp = 50;
        
        input = Experiments.Diss.conference_room(num_sp, num_wpn);% true);
        %%%
        input.config.optimization = Configurations.Optimization.Discrete.mspqm;
        %         output_filename = sprintf('tmp/conference_room/mspqm/mspqm__%d_%d_%d.mat', input.discretization.num_sensors, input.discretization.num_positions, input.discretization.num_comb);
        %%
        mspqm = input;
        mspqm.filename = Optimization.Discrete.Models.mspqm(mspqm.discretization, mspqm.quality, mspqm.config.optimization);
        %%
        bspqm = input;
        bspqm.config.optimization = Configurations.Optimization.Discrete.bspqm;
        bspqm.filename = Optimization.Discrete.Models.bspqm(bspqm.discretization, bspqm.quality, bspqm.config.optimization);
        %%
        mspqm_notc = input;
        mspqm_notc.config.optimization.type = 'mspqm_notc';
        mspqm_notc.filename = Optimization.Discrete.Models.mspqm_notc(mspqm_notc.discretization, mspqm_notc.quality, mspqm_notc.config.optimization);
        %%
        mspqm_ind = input;
        mspqm_ind.config.optimization.type = 'mspqm_ind';
        mspqm_ind.filename = Optimization.Discrete.Models.mspqm_ind(mspqm_ind.discretization, mspqm_ind.quality, mspqm_ind.config.optimization);
        %         input.solution = solution;
        %         [input.solution.discretization, input.solution.quality] = Evaluation.filter(solution, input.discretization, input.config.discretization);
        %%%
        %         mspqm.solfile = Optimization.Discrete.Solver.cplex.start(mspqm.filename, cplex);
        %%
        %         mspqm_notc.solfile = Optimization.Discrete.Solver.cplex.start(mspqm_notc.filename, cplex);
        [mspqm_ind.solfile, mspqm_ind.logfile] = Optimization.Discrete.Solver.cplex.start(mspqm_ind.filename, cplex);
        mspqm_ind.log = Optimization.Discrete.Solver.cplex.read_log(mspqm_ind.logfile);
        mspqm_ind.solution = Optimization.Discrete.Solver.cplex.read_solution(mspqm_ind.solfile);
        
        %%
        [bspqm.solfile, bspqm.logfile] = Optimization.Discrete.Solver.cplex.start(bspqm.filename, cplex);
        bspqm.log = Optimization.Discrete.Solver.cplex.read_log(bspqm.logfile);
        bspqm.solution = Optimization.Discrete.Solver.cplex.read_solution(bspqm.solfile);
        
        %         save(output_filename, 'input');
        %% TEST solving with and without two sensors per wp
        
    end
end

%%
num_wpn = 0;
num_sp = 0;

mspqm = Experiments.Diss.conference_room(num_sp, num_wpn);
mspqm.config.optimization = Configurations.Optimization.Discrete.mspqm;
mspqm_ind.config.optimization.type = 'mspqm';
mspqm.filename = Optimization.Discrete.Models.mspqm(mspqm.discretization, mspqm.quality, mspqm.config.optimization);
[mspqm.solfile, mspqm.logfile] = Optimization.Discrete.Solver.cplex.start(mspqm.filename, cplex);
mspqm.log = Optimization.Discrete.Solver.cplex.read_log(mspqm.logfile);
mspqm.solution = Optimization.Discrete.Solver.cplex.read_solution(mspqm.solfile);
[mspqm.solution.discretization, mspqm.solution.quality] = Evaluation.filter(mspqm.solution, mspqm.discretization, mspqm.config.quality);
mspqm.solution.discretization.wpn_qualities_max = cellfun(@max, mspqm.solution.quality.wss.val );

%%
num_wpn = 0;
num_sp = 0;

mspqm_ind = Experiments.Diss.conference_room(num_sp, num_wpn);
mspqm_ind.config.optimization = Configurations.Optimization.Discrete.mspqm;
mspqm_ind_ind.config.optimization.type = 'mspqm_ind';
mspqm_ind.filename = Optimization.Discrete.Models.mspqm_ind(mspqm_ind.discretization, mspqm_ind.quality, mspqm_ind.config.optimization);
[mspqm_ind.solfile, mspqm_ind.logfile] = Optimization.Discrete.Solver.cplex.start(mspqm_ind.filename, cplex);
mspqm_ind.log = Optimization.Discrete.Solver.cplex.read_log(mspqm_ind.logfile);
mspqm_ind.solution = Optimization.Discrete.Solver.cplex.read_solution(mspqm_ind.solfile);
[mspqm_ind.solution.discretization, mspqm_ind.solution.quality] = Evaluation.filter(mspqm_ind.solution, mspqm_ind.discretization, mspqm_ind.config.quality);
mspqm_ind.solution.discretization.wpn_qualities_max = cellfun(@max, mspqm_ind.solution.quality.wss.val );


%%
num_wpn = 0;
num_sp = 0;

bspqm = Experiments.Diss.conference_room(num_sp, num_wpn);
bspqm.config.optimization = Configurations.Optimization.Discrete.bspqm;
mspqm_ind.config.optimization.type = 'bspqm';
bspqm.filename = Optimization.Discrete.Models.bspqm(bspqm.discretization, bspqm.quality, bspqm.config.optimization);
[bspqm.solfile, bspqm.logfile] = Optimization.Discrete.Solver.cplex.start(bspqm.filename, cplex);
bspqm.log = Optimization.Discrete.Solver.cplex.read_log(bspqm.logfile);
bspqm.solution = Optimization.Discrete.Solver.cplex.read_solution(bspqm.solfile);

%%
num_wpn = 0;
num_sp = 0;

ospqm = Experiments.Diss.conference_room(num_sp, num_wpn);
ospqm.config.optimization = Configurations.Optimization.Discrete.ospqm;
mspqm_ind.config.optimization.type = 'ospqm';
ospqm.filename = Optimization.Discrete.Models.ospqm(ospqm.discretization, ospqm.quality, ospqm.config.optimization);
[ospqm.solfile, ospqm.logfile] = Optimization.Discrete.Solver.cplex.start(ospqm.filename, cplex);
ospqm.log = Optimization.Discrete.Solver.cplex.read_log(ospqm.logfile);
ospqm.solution = Optimization.Discrete.Solver.cplex.read_solution(ospqm.solfile);


%%
fsize = [325 420];
pos = [0 0];
input = mspqm_ind;
% input = mspqm;
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