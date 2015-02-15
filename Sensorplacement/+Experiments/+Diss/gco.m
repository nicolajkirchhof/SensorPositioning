%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0:10:50;
% num_wpns = 0:10:500;
% names = {'conference_room', 'small_flat'}; %, 'large_flat', 'office_floor'};
names = {'large_flat', 'office_floor'};

num_sps =  0:10:500;
num_wpns = 0:10:500;
iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps)*numel(names);
write_log([], '#off');
for id_n = 1:numel(names)
    gco = cell(numel(num_sps), numel(num_wpns));
    name = names{id_n};
    for id_wpn = 1:numel(num_wpns)
        for id_sp = 1:numel(num_sps)
            num_wpn = num_wpns(id_wpn);
            num_sp = num_sps(id_sp);
            
            %%
            input = Experiments.Diss.(name)(num_sp, num_wpn);% true);
            %%%
            input.config.optimization.name = input.name;
            gco_config = Configurations.Optimization.Discrete.gco;
            %%
%             config.optimization = Configurations.Optimization.Discrete.gco;
            solution = Optimization.Discrete.Greedy.gco(input.discretization, input.quality, gco_config);
            [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, input.config.discretization);
            
            %%
            %         input = gco;
            solution.num_sp = num_sp;
            solution.num_wpn = num_wpn;
            gco{id_sp, id_wpn} = solution;
            iteration = iteration + 1;
            if toc(tme)>next
                fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
                next = toc(tme)+stp;
            end
            
        end
    end
    output_filename = sprintf('tmp/%s/gco.mat', name);
    save(output_filename, 'gco');
end
return
%%
close all;
fsize = [325 420];
pos = [0 0];
num_wpn = 500;
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
name = names{1};
for   num_sp = 500%0:50:500
    input = Experiments.Diss.(name)(num_sp, num_wpn);% true);
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
    axis auto;
%     ylim([0 8000]);
%     xlim([0 5500]);
    pos(1) = pos(1)+325;
    if pos(1) > 1590
        pos = [0 500];
    end
end
