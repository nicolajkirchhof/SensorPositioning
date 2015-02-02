%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 500;
% num_sps =  0:10:100;
num_wpns = 0:10:500;
num_sps =  0:10:500;
% cplex = 'C:\Users\Nick\App\Cplex\cplex\bin\x64_win64\cplex.exe';
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
    gsss = cell(numel(num_sps), numel(num_wpns));
    name = names{id_n};
    for id_wpn = 1:numel(num_wpns)
        for id_sp = 1:numel(num_sps)
            num_wpn = num_wpns(id_wpn);
            num_sp = num_sps(id_sp);
            %%
%             num_wpn = 0;
%             num_sp = 0;
            %%
            input = Experiments.Diss.(name)(num_sp, num_wpn);
            input.config.optimization.name = input.name;
            
            solution.solfile = sprintf('tmp/%s/gsss/ssc_%s_%d_%d_.sol', name, name, num_sp, num_wpn);
            %%
            if ~exist(solution.solfile, 'file')
                gen = Configurations.Common.generic();
                gen.workdir = sprintf('tmp/%s/gsss', name);
                ssc_config = Configurations.Optimization.Discrete.ssc(gen);
                ssc_config.name = name;
                solution.filename = Optimization.Discrete.Models.ssc(input.discretization, [], ssc_config);
                [solution.solfile, solution.logfile] = Optimization.Discrete.Solver.cplex.start(solution.filename, cplex, false);
            else
                solution.logfile = sprintf('tmp/%s/gsss/ssc_%s_%d_%d_.log', name, name, num_sp, num_wpn);
            end
            %%
            solution_coverage = Optimization.Discrete.Solver.cplex.read_solution(solution.solfile);
            solution_coverage_log = Optimization.Discrete.Solver.cplex.read_log(solution.logfile);
            
            config.optimization = Configurations.Optimization.Discrete.gsss;
            solution = Optimization.Discrete.Greedy.gsss(input.discretization, input.quality, solution_coverage, config.optimization);
            [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, input.config.discretization);
            
            solution.quality.wss = rmfield(solution.quality.wss, {'valbw'; 'valsum'});
            solution.quality = rmfield(solution.quality, 'ws');
            solution.discretization.spo = uint8(solution.discretization.spo);
            solution.discretization.vm = uint8(solution.discretization.vm);
            solution.discretization.spo_ids = cellfun(@(x) uint16(x), solution.discretization.spo_ids, 'uniformoutput', false);
            solution.num_sp = num_sp;
            solution.num_wpn = num_wpn;
            solution.ssc.iterations = solution_coverage.iterations;
            solution.ssc.sensors_selected = solution_coverage.sensors_selected;
            solution.ssc.solutiontime = solution_coverage_log.solutiontime;
            %%
            gsss{id_sp, id_wpn} = solution;
            
            iteration = iteration + 1;
            if toc(tme)>next
                fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
                next = toc(tme)+stp;
            end
            
        end
    end
    output_filename = sprintf('tmp/%s/gsss.mat', name);
    save(output_filename, 'gsss');
end
return;
%%

fsize = [325 420];
pos = [0 0];
close all;
% names = {'conference_room', 'small_flat'}; %, 'large_flat', 'office_floor'};
% names = {'large_flat', 'office_floor'};
% names = {'office_floor'};
names = {'conference_room'};
name = names{1};
num_wpn = 0;
for   num_sp = 0 %:100:500
    input = Experiments.Diss.(name)(num_sp, num_wpn);
    input.config.optimization.name = input.name;
    
    gen = Configurations.Common.generic();
    gen.workdir = sprintf('tmp/%s/gsss', name);
    ssc_config = Configurations.Optimization.Discrete.ssc(gen);
    ssc_config.name = name;
    solution.filename = Optimization.Discrete.Models.ssc(input.discretization, [], ssc_config);
    
    [solution.solfile, solution.logfile] = Optimization.Discrete.Solver.cplex.start(solution.filename, cplex, false);
    solution_coverage = Optimization.Discrete.Solver.cplex.read_solution(solution.solfile);
    solution_coverage.log = Optimization.Discrete.Solver.cplex.read_log(solution.logfile);
    solution_coverage.solution = solution;
    
    config.optimization = Configurations.Optimization.Discrete.gsss;
    solution = Optimization.Discrete.Greedy.gsss(input.discretization, input.quality, solution_coverage, config.optimization);
    [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, input.config.discretization);
    
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
%     end
% end
