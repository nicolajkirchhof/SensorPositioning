%% Add decomposition parts
clearvars -except all_eval
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
idn = 1;
name = names{idn};
opt_name = 'nonlin_it';
lookupdir = sprintf('tmp/%s/cmqm/', name);
files = dir(sprintf('%s*%s*.mat', lookupdir, opt_name));
loop_display(numel(files), 5);
cmqm_nonlin_it = cell(51, 51); 

%%
for idf = 1:numel(files)
    %%
    file = files(idf);
    matfile = [lookupdir file.name];
    input_nonlin{idf} = load(matfile);
    
end
%%
cmqm_nonlin_it = cell(51, 51); 
for idic = 1:numel(input_nonlin);
    for ids = 1:numel(input_nonlin{idic}.cmcqm_cmaes_it)
        if ~isempty(input_nonlin{idic}.cmcqm_cmaes_it{ids})
            id_sp = input_nonlin{idic}.cmcqm_cmaes_it{ids}.num_sp/10+1;
            id_wpn = input_nonlin{idic}.cmcqm_cmaes_it{ids}.num_wpn/10+1;
            cmqm_nonlin_it{id_sp, id_wpn} = input_nonlin{idic}.cmcqm_cmaes_it{ids};
    
        end
    end
end
% save tmp\conference_room\cmqm_nonlin_it.mat cmqm_nonlin_it
%%
clearvars -except all_eval;
%%
% load tmp\conference_room\cmqm_nonlin_it.mat
%%
for ids = 1:numel(cmqm_nonlin_it)
        if ~isempty(cmqm_nonlin_it{ids})
            cmqm_nonlin_it{ids}.solutions{end-1}.sensors_selected = cmqm_nonlin_it{ids}.solutions{end-1}.discretization.sp;
            cmqm_nonlin_it{ids}.sol = cmqm_nonlin_it{ids}.solutions{end-1};
            
    %%
%             cmqm_nonlin_it{ids}.quality.sum_max = sum(cellfun(@(x) max(x), cmqm_nonlin_it{ids}.sol.quality.wss.val));
            cmqm_nonlin_it{ids}.quality.sum_max = -cmqm_nonlin_it{ids}.sol.fmin;
            cmqm_nonlin_it{ids}.sensors_selected =  1:size(cmqm_nonlin_it{ids}.sol.sensors_selected, 2);
            cmqm_nonlin_it{ids}.all_wpn = cmqm_nonlin_it{ids}.sol.discretization.num_positions;
            cmqm_nonlin_it{ids}.all_sp = cmqm_nonlin_it{ids}.sol.discretization.num_sensors;
            
        end
end
%%
save(sprintf('tmp/%s/%s.mat', name, opt_name), opt_name);

%%
input = Experiments.Diss.conference_room(cmqm_nonlin_it{ids}.num_sp, cmqm_nonlin_it{ids}.num_wpn);
cmqm_nonlin_it{ids}.solutions(end) = [];
sol = cmqm_nonlin_it{ids}.solutions{end-1};
sol.discretization = input.discretization;
sol.discretization.num_sensors = size(sol.sp, 2);
sol.sensors_selected = 1:numel(sol.discretization.num_sensors);

%%% ONLY CONVERT LAST VALID!!!
[sol.discretization.sp, sol.discretization.vfovs, sol.discretization.vm] = ...
    Discretization.Sensorspace.vfov(sol.sp, input.environment, sol.discretization.wpn, input.config.discretization, true);
[sol.discretization.spo, sol.discretization.spo_ids] = Discretization.Sensorspace.sameplace(sol.discretization.sp, input.config.discretization.sensor.fov);
[sol.discretization.sc, sol.discretization.sc_wpn] = Discretization.Sensorspace.sensorcomb(sol.discretization.vm, sol.discretization.spo, input.config.discretization);
sol.quality = Quality.generate(sol.discretization, Configurations.Quality.diss);
sol.quality.wss.val
%%
cmqm_nonlin_it{ids}.solutions{end-1} = sol;
