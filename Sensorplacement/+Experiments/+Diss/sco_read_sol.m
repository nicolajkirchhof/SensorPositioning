%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0:10:50;
% num_wpns = 0:10:490;
num_wpns = 0:10:500;
num_sps =  0:10:500;

% names = {'conference_room', 'small_flat'} % 'large_flat', 'office_floor'};
names = {'large_flat'}%, 'office_floor'};
% names = {'office_floor'}
% names = {'conference_room'};

iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps)*numel(names);

% write_log([], '#off');
%%
for id_n = 1:numel(names)
    sco = cell(numel(num_sps), numel(num_wpns));
    name = names{id_n};
    for id_wpn = 1:numel(num_wpns)
        for id_sp = 1:numel(num_sps)
            %%
            num_wpn = num_wpns(id_wpn);
            num_sp = num_sps(id_sp);

            filename = sprintf('tmp/%s/sco/sco_%s_%d_%d_.sol.ex', name, name, num_sp, num_wpn);
            %%
%             fn_full = sprintf('tmp/%s/sco/sco_%s_%d_%d_.sol', name, name, num_sp, num_wpn);
%             sol = Optimization.Discrete.Solver.cplex.read_solution(fn_full);
            %%
            if exist(filename, 'file') > 0
            input = Experiments.Diss.(name)(num_sp, num_wpn);
            fid = fopen(filename);
            
            tline = fgetl(fid);
            sc_selected = [];
            sensors_selected = [];
            while ischar(tline)
%                 disp(tline)
                vars = textscan(tline, '<variable name="s%ds%d" index="%d" value="1"/>');
                sc_selected = [sc_selected vars{3}+1];
                sensors_selected = [sensors_selected vars{1:2}];
                tline = fgetl(fid);
            end
            fclose(fid);
            %%
            solution = [];
            solution.sensors_selected = uint16(unique(sensors_selected));
            solution.sc_selected = sc_selected;
            [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, Configurations.Quality.diss);
            %%%
%             for fn = fieldnames(log)'
%                 field = fn{1};
%                 solution.(field) = log.(field);
%             end
            solution.num_sp = num_sp;
            solution.num_wpn = num_wpn;
            solution.filename = filename;
            solution.quality.sum_max = sum(cellfun(@(x) max(x), solution.quality.wss.val));
            solution.quality.sum = sum(cellfun(@(x) sum(x), solution.quality.wss.val));
            opt_prep = Optimization.Continuous.prepare_opt(input, solution.discretization.sp);
            qualityarea = (0.9-Optimization.Continuous.fitfct.cmcqm_nostat(opt_prep))*100;
            solution.quality.area_covered = qualityarea;
            solution.quality = rmfield(solution.quality, {'wss'});
            solution.all_wpn = solution.discretization.num_positions;
            solution.all_sp = solution.discretization.num_sensors;
            solution = rmfield(solution, {'discretization'});
%             solution.discretization.spo = uint8(solution.discretization.spo);
%             solution.discretization.vm = uint8(solution.discretization.vm);
%             solution.discretization.spo_ids = cellfun(@(x) uint16(x), solution.discretization.spo_ids, 'uniformoutput', false);
%             
            sco{id_sp, id_wpn} = solution;            
            %%
            iteration = iteration + 1;
            if toc(tme)>next
                fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
                next = toc(tme)+stp;
            end
            end
        end
    end
    output_filename = sprintf('tmp/%s/sco.mat', name);
    save(output_filename, 'sco');
end