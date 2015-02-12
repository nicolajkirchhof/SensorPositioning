%%
cplex = [getenv('home') 'App\Cplex\cplex\bin\x64_win64\cplex.exe'];

%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0:10:50;
% names = {'conference_room', 'small_flat'} %, 'large_flat', 'office_floor'};
names = {'large_flat'};
% names = {'office_floor'}

num_wpns = 100:10:200;
num_sps =  100:10:200;
cnt = 100;
% gco = cell(numel(num_sps), numel(num_wpns));
for id_n = 1:numel(names)
    name = names{id_n};
    for id_wpn = 1:numel(num_wpns)
        for id_sp = 1:numel(num_sps)
            num_wpn = num_wpns(id_wpn);
            num_sp = num_sps(id_sp);
            
            %%
            %         num_wpn = 0;
            %         num_sp = 50;
            
            input = Experiments.Diss.(name)(num_sp, num_wpn);% true);
            
            gen = Configurations.Common.generic();
            gen.workdir = sprintf('tmp/mspqm');
            mspqm_config = Configurations.Optimization.Discrete.mspqm(gen);
            mspqm_config.name = sprintf('%d_%s', cnt, name);
            filename = Optimization.Discrete.Models.mspqm(input.discretization, input.quality, mspqm_config);
            
            cnt = cnt + 1;
        end
    end
end

%%
num_wpn = 200;
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
name = names{1};
fsize = [325 420];
pos = [0 0];
close all;
for num_sp = 200 %
    input = Experiments.Diss.(name)(num_sp, num_wpn);% true);
    
    gen = Configurations.Common.generic();
    gen.workdir = sprintf('tmp/mspqm');
    mspqm_config = Configurations.Optimization.Discrete.mspqm(gen);
    mspqm_config.name = name;
    input.filename = Optimization.Discrete.Models.mspqm(input.discretization, input.quality, mspqm_config);
    %%
    [input.solfile, input.logfile] = Optimization.Discrete.Solver.cplex.start(input.filename, cplex);
    input.log = Optimization.Discrete.Solver.cplex.read_log(input.logfile);
    solution = Optimization.Discrete.Solver.cplex.read_solution(input.solfile);
    [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, Configurations.Quality.diss);
    solution.discretization.wpn_qualities_max = cellfun(@max, solution.quality.wss.val );
    
    figure;
    Discretization.draw(input.discretization, input.environment);
    hold on;
    Discretization.draw_wpn_max_qualities(solution.discretization, solution.quality);
    Discretization.draw_vfos(input.discretization, solution);
    allqvall = cell2mat(solution.quality.wss.val);
    title(sprintf('Num SP %d, Sel SP %d, Num WPN %d\n MinQ %.4g, MaxQ %.4g,\n Mean/dQ %.4g %.4g SumQ %.4g ',...
        input.discretization.num_sensors, solution.discretization.num_sensors, input.discretization.num_positions,...
        min(allqvall), max(allqvall), mean(allqvall), median(allqvall), sum(allqvall)));
    set(gcf, 'Position', [pos fsize]);
    axis equal
    axis auto
    pos(1) = pos(1)+325;
    if pos(1) > 1590
        pos = [0 500];
    end
end


%%
fsize = [325 420];
pos = [0 0];
% input = mspqm;
figure;
Discretization.draw(input.discretization, input.environment);
hold on;
Discretization.draw_wpn_max_qualities(solution.discretization, solution.quality);
Discretization.draw_vfos(input.discretization, solution);
allqvall = cell2mat(solution.quality.wss.val);
title(sprintf('Num SP %d, Sel SP %d, Num WPN %d\n MinQ %.4g, MaxQ %.4g,\n Mean/dQ %.4g %.4g SumQ %.4g ',...
    input.discretization.num_sensors, solution.discretization.num_sensors, input.discretization.num_positions,...
    min(allqvall), max(allqvall), mean(allqvall), median(allqvall), sum(allqvall)));
set(gcf, 'Position', [pos fsize]);
pos(1) = pos(1)+325;
if pos(1) > 1590
    pos = [0 500];
end