%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0:10:50;
% num_wpns = 0:10:490;
num_wpns = 0:10:500;
num_sps =  0:10:500;
cplex = [getenv('home') '\App\Cplex\cplex\bin\x64_win64\cplex.exe'];

names = {'conference_room', 'small_flat'} % 'large_flat', 'office_floor'};
% names = {'large_flat', 'office_floor'};
% names = {'office_floor'}
% names = {'conference_room'};

iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps)*numel(names);

% write_log([], '#off');

for id_n = 1:numel(names)
%     sco = cell(numel(num_sps), numel(num_wpns));
    name = names{id_n};
    for id_wpn = 1:numel(num_wpns)
        for id_sp = 1:numel(num_sps)
            num_wpn = num_wpns(id_wpn);
            num_sp = num_sps(id_sp);
           
            filename = sprintf('tmp/%s/sco/sco_%s_%d_%d_.lp', name, name, num_sp, num_wpn);
            
            if exist(filename, 'file') == 0
            input = Experiments.Diss.(name)(num_sp, num_wpn);
            input.config.optimization.name = input.name;
            gen = Configurations.Common.generic();
            gen.workdir = sprintf('tmp/%s/sco', name);
            stcm_config = Configurations.Optimization.Discrete.sco(gen);
            stcm_config.name = name;
            problemfile = Optimization.Discrete.Models.sco(input.discretization, input.quality, stcm_config);
            %%
            [solutionfile, logfile] = Optimization.Discrete.Solver.cplex.start(problemfile, cplex, true);
            
            %%
            end
        end
    end
end
%             solution = Optimization.Discrete.Solver.cplex.read_solution(solutionfile);
%             log = Optimization.Discrete.Solver.cplex.read_log(logfile);
%             [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, Configurations.Quality.diss);
% %             solution.discretization.wpn_qualities_max = cellfun(@max, solution.quality.wss.val );
%             %%
% %             for fn = fieldnames(log)'
% %                 field = fn{1};
% %                 solution.(field) = log.(field);
% %             end
%             solution.num_sp = num_sp;
%             solution.num_wpn = num_wpn;
%             solution.filename = problemfile;
%             solution.quality.sum_max = sum(cellfun(@(x) max(x), solution.quality.wss.val));
%             solution.quality.sum = sum(cellfun(@(x) max(x), solution.quality.wss.val));
%             opt_prep = Optimization.Continuous.prepare_opt(input, solution.discretization.sp);
%             qualityarea = (0.9-Optimization.Continuous.fitfct.cmcqm_nostat(opt_prep))*100;
%             solution.quality.area_covered = qualityarea;
%             solution.quality = rmfield(solution.quality, {'wss'});
%             solution.all_wpn = solution.discretization.num_positions;
%             solution.all_sp = solution.discretization.num_sensors;
%             solution = rmfield(solution, {'discretization';'name';'wpn_qualities';'env_qualities';'env_points';'linearConstraints';'variables';'status';'statusstring' });
% %             solution.discretization.spo = uint8(solution.discretization.spo);
% %             solution.discretization.vm = uint8(solution.discretization.vm);
% %             solution.discretization.spo_ids = cellfun(@(x) uint16(x), solution.discretization.spo_ids, 'uniformoutput', false);
% %             
%             sco{id_sp, id_wpn} = solution;            
%             %%
%             iteration = iteration + 1;
%             if toc(tme)>next
%                 fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
%                 next = toc(tme)+stp;
%             end
%         end
%     end
%     output_filename = sprintf('tmp/%s/sco.mat', name);
%     save(output_filename, 'sco');
% end

return;
