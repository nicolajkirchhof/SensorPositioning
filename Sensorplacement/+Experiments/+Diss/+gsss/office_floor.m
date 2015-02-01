%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0;
% num_sps =  0:10:100;
% cplex = 'C:\Users\Nick\App\Cplex\cplex\bin\x64_win64\cplex.exe';
cplex = [getenv('home') 'App\Cplex\cplex\bin\x64_win64\cplex.exe'];

%%
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
        
        output_filename = sprintf('tmp/office_floor/gsss/gsss__%d_%d.mat', num_sp, num_wpn);
                
        if exist(output_filename, 'file')> 0
            continue
        end
        %%
%         num_wpn = 500;
%         num_sp = 0;

        
        
        input = Experiments.Diss.office_floor(num_sp, num_wpn);% true);
        %%%
%         input.config.optimization = Configurations.Optimization.Discrete.gsss;
        input.config.optimization.name = input.name;
        
%         solution_coverage = Optimization.Discrete.Greedy.gssc(input.discretization);
        %%%
%         input.solution_coverage = solution_coverage;
        ssc_config = Configurations.Optimization.Discrete.ssc;
        ssc_config.common.workdir = 'tmp\office_floor\gsss';
        ssc.filename = Optimization.Discrete.Models.ssc(input.discretization, [], ssc_config);
        [ssc.solfile, ssc.logfile] = Optimization.Discrete.Solver.cplex.start(ssc.filename, cplex, false);
        solution_coverage = Optimization.Discrete.Solver.cplex.read_solution(ssc.solfile);
        solution_coverage.log = Optimization.Discrete.Solver.cplex.read_log(ssc.logfile);
        solution_coverage.ssc = ssc;
        
        config.optimization = Configurations.Optimization.Discrete.gsss;
        solution = Optimization.Discrete.Greedy.gsss(input.discretization, input.quality, solution_coverage, config.optimization);
        [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, input.config.discretization);
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
fsize = [325 420];
pos = [0 0];
num_wpn = 500;
for   num_sp = 0:50:500
    input = Experiments.Diss.office_floor(num_sp, num_wpn);% true);
    %%%
    input.config.optimization.name = input.name;
    gco_config = Configurations.Optimization.Discrete.gco;
    
    config.optimization = Configurations.Optimization.Discrete.gco;
    solution = Optimization.Discrete.Greedy.gco(input.discretization, input.quality, config.optimization);
    [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, input.config.discretization);
    
    discretization = input.discretization;
    figure;
    Discretization.draw(discretization, input.environment);
    hold on;
    Discretization.draw_wpn_max_qualities(solution.discretization, solution.quality);
    Discretization.draw_vfos(discretization, solution);
    allqval = cell2mat(solution.quality.wss.val);
    wpnqval = cellfun(@max, solution.quality.wss.val);
    title(sprintf('Num SP %d, Sel SP %d, Num WPN %d\n MinQ %.4g, MaxQ %.4g,\n Mean/dQ %.4g %.4g SumQ %.4g ',...
        discretization.num_sensors, solution.discretization.num_sensors, discretization.num_positions,...
        min(wpnqval), max(wpnqval), mean(allqval), median(wpnqval), sum(wpnqval)));
    set(gcf, 'Position', [pos fsize]);
    axis equal;
ylim([0 15000]);
xlim([0 29000]);
    pos(1) = pos(1)+325;
    if pos(1) > 1590
        pos = [0 500];
    end
end