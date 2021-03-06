%%
close all;
% clear variables;
%%%
clearvars -except gco
% num_sp = 0:20:200
% num_wpns = 0:10:50;
% num_wpns = 0:10:500;
% names = {'conference_room', 'small_flat'}; %, 'large_flat', 'office_floor'};
% names = {'large_flat', 'office_floor'};
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};

num_sps =  500;
% num_wpns = 0:10:500;
% num_wpns = 0:10:500;
num_wpns = 0:50:500;
% num_wpns = 0;
iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps)*numel(names);
write_log([], '#off');
%%%
for id_n = 1:numel(names)
    cmcqm_nonlin_it = cell(numel(num_sps), numel(num_wpns));
    name = names{id_n};
    if id_n > 1 || exist('gco', 'var') == 0
        load(sprintf('tmp/%s/gco.mat', name));
    end
    % %     load(sprintf('tmp/%s/cmcqm_nonlin_it.mat', name));
    %%
    for id_wpn = 1:numel(num_wpns)
        for id_sp = 1:numel(num_sps)
            num_wpn = num_wpns(id_wpn);
            num_sp = num_sps(id_sp);
            
            %%
            %             if isempty(cmcqm_nonlin_it{id_sp, id_wpn})
            output_filename = sprintf('tmp/%s/cmcqm/nonlin_it_%d_%d.mat', name, num_sp, num_wpn);
            
            if exist(output_filename, 'file') == 0
                sol = gco{(num_sp/10)+1, (num_wpn/10)+1};
                input = Experiments.Diss.(name)(sol.num_sp, sol.num_wpn);
                input.solution = sol;
                config.timeperiteration = 14400; %7200;
                config.restarts = 1000*id_n;
                config.probingtime = 60*(id_n*5); %0;
                config.UseParallel = false;
                config.verbose = false;
                solutions = Optimization.Continuous.cmcqm_nonlin_it(input, config);
                
                %%
                solution = [];
                %         input = cmcqm_nonlin_it;ls
                solution.solutions = solutions;
                solution.num_sp = num_sp;
                solution.num_wpn = num_wpn;
                solution.sol = sol;
%                 cmcqm_nonlin_it{id_sp, (num_wpn/10)+1} = solution;
                %             end
                iteration = iteration + 1;
                fprintf(1, '\n\n sp %d wpn %d\n\n', num_sp, num_wpn);
                if toc(tme)>next
                    fprintf(1, '\n\n%g pct %g sec to go sp %d wpn %d\n\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration), num_sp, num_wpn);
                    next = toc(tme)+stp;
                end
                
                save(output_filename, 'solution');
            end
        end
        %         output_filename = sprintf('tmp/%s/cmcqm/nonlin_it_%d_%d.mat', name, num_sp, num_wpn);
        
    end
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
    cmcqm_nonlin_it_config = Configurations.Optimization.Discrete.cmcqm_nonlin_it;
    
    config.optimization = Configurations.Optimization.Discrete.cmcqm_nonlin_it;
    solution = Optimization.Discrete.Greedy.cmcqm_nonlin_it(input.discretization, input.quality, config.optimization);
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
