%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0:10:50;
% num_wpns = 0:10:490;
num_wpns = 0:10:500;
num_sps =  0:10:500;
cplex = [getenv('home') 'App\Cplex\cplex\bin\x64_win64\cplex.exe'];

names = {'conference_room', 'small_flat'}; %, 'large_flat', 'office_floor'};
% names = {'large_flat', 'office_floor'};
% names = {'office_floor'}
% names = {'conference_room'};

iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps)*numel(names);

write_log([], '#off');

for id_n = 1:numel(names)
    stcm = cell(numel(num_sps), numel(num_wpns));
    name = names{id_n};
    for id_wpn = 1:numel(num_wpns)
        for id_sp = 1:numel(num_sps)
            num_wpn = num_wpns(id_wpn);
            num_sp = num_sps(id_sp);
            
            input = Experiments.Diss.(name)(num_sp, num_wpn);
            input.config.optimization.name = input.name;
            
            gen = Configurations.Common.generic();
            gen.workdir = sprintf('tmp/%s/stcm', name);
            stcm_config = Configurations.Optimization.Discrete.stcm(gen);
            stcm_config.name = name;
            problemfile = Optimization.Discrete.Models.stcm(input.discretization, [], stcm_config);
            %%
            [solutionfile, logfile] = Optimization.Discrete.Solver.cplex.start(problemfile, cplex, false);
            solution = Optimization.Discrete.Solver.cplex.read_solution(solutionfile);
            log = Optimization.Discrete.Solver.cplex.read_log(logfile);
            [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, Configurations.Quality.diss);
            solution.discretization.wpn_qualities_max = cellfun(@max, solution.quality.wss.val );
            %%
            for fn = fieldnames(log)'
                field = fn{1};
                solution.(field) = log.(field);
            end
            solution.num_sp = num_sp;
            solution.num_wpn = num_wpn;
            solution.filename = problemfile;
            solution.quality.wss = rmfield(solution.quality.wss, {'valbw'; 'valsum'});
            solution.quality = rmfield(solution.quality, 'ws');
            solution.discretization.spo = uint8(solution.discretization.spo);
            solution.discretization.vm = uint8(solution.discretization.vm);
            solution.discretization.spo_ids = cellfun(@(x) uint16(x), solution.discretization.spo_ids, 'uniformoutput', false);
            
            stcm{id_sp, id_wpn} = solution;            
            %%
            iteration = iteration + 1;
            if toc(tme)>next
                fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
                next = toc(tme)+stp;
            end
        end
    end
    output_filename = sprintf('tmp/%s/stcm.mat', name);
    save(output_filename, 'stcm');
end

return;
%%
close all;
fsize = [325 420];
pos = [0 0];
close all;
% names = {'conference_room', 'small_flat'}; %, 'large_flat', 'office_floor'};
% names = {'large_flat', 'office_floor'};
% names = {'office_floor'};
names = {'conference_room'};
name = names{1};
num_wpn = 0;
for   num_sp = 0:100:500
    input = Experiments.Diss.(name)(num_sp, num_wpn);
    input.config.optimization.name = input.name;
    
    gen = Configurations.Common.generic();
    gen.workdir = sprintf('tmp/%s/stcm', name);
    stcm_config = Configurations.Optimization.Discrete.stcm(gen);
    stcm_config.name = name;
    problemfile = Optimization.Discrete.Models.stcm(input.discretization, [], stcm_config);
    %%
    [solutionfile, logfile] = Optimization.Discrete.Solver.cplex.start(problemfile, cplex, false);
    solution = Optimization.Discrete.Solver.cplex.read_solution(solutionfile);
    log = Optimization.Discrete.Solver.cplex.read_log(logfile);
    [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, Configurations.Quality.diss);
    solution.discretization.wpn_qualities_max = cellfun(@max, solution.quality.wss.val );
    %%
    for fn = fieldnames(log)'
        field = fn{1};
        solution.(field) = log.(field);
    end
    solution.num_sp = num_sp;
    solution.num_wpn = num_wpn;
    solution.filename = problemfile;
    solution.quality.wss = rmfield(solution.quality.wss, {'valbw'; 'valsum'});
    solution.quality = rmfield(solution.quality, 'ws');
    solution.discretization.spo = uint8(solution.discretization.spo);
    solution.discretization.vm = uint8(solution.discretization.vm);
    solution.discretization.spo_ids = cellfun(@(x) uint16(x), solution.discretization.spo_ids, 'uniformoutput', false);
    
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