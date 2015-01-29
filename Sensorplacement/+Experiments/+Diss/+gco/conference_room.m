%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0:10:50;
% num_wpns = 0:10:500;
num_sps =  0:10:500;
num_wpns = 500;
% gco = cell(numel(num_sps), numel(num_wpns));

iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps);
write_log([], '#off');
for id_wpn = 1:numel(num_wpns)
    for id_sp = 1:numel(num_sps)
        num_wpn = num_wpns(id_wpn);
        num_sp = num_sps(id_sp);
        
        %%
        %         num_wpn = 0;
        %         num_sp = 0;
        input = Experiments.Diss.conference_room(num_sp, num_wpn);% true);
        %%%
        input.config.optimization.name = input.name;
        gco_config = Configurations.Optimization.Discrete.gco;
        
        gco.config.optimization = Configurations.Optimization.Discrete.gco;
        gco.solution = Optimization.Discrete.Greedy.gco(input.discretization, input.quality, gco.config.optimization);
        [gco.solution.discretization, gco.solution.quality] = Evaluation.filter(gco.solution, input.discretization, input.config.discretization);
        %%
        input = gco;
        input.num_sp = num_sp;
        input.num_wpn = num_wpn;
        output_filename = sprintf('tmp/conference_room/gco/gco__%d_%d.mat', num_sp, num_wpn);
        save(output_filename, 'input');
        iteration = iteration + 1;
        if toc(tme)>next
            fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
            next = toc(tme)+stp;
        end
                
    end
end
