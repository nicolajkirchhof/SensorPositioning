%% Add decomposition parts
% clearvars;
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
idn = 1;
name = names{idn};
opt_name = 'cmaes_it';
lookupdir = sprintf('tmp/%s/cmqm/', name);
files = dir(sprintf('%s*%s*.mat', lookupdir, opt_name));
loop_display(numel(files), 5);
cmqm_cmaes_it = cell(51, 51); 

%%
for idf = 1:numel(files)
    %%
    file = files(idf);
    matfile = [lookupdir file.name];
    input_cmqm{idf} = load(matfile);
    
end
%%
cmqm_cmaes_it = cell(51, 51); 
for idic = 1:numel(input_cmqm);
    for ids = 1:numel(input_cmqm{idic}.cmcqm_cmaes_it)
        if ~isempty(input_cmqm{idic}.cmcqm_cmaes_it{ids})
            id_sp = input_cmqm{idic}.cmcqm_cmaes_it{ids}.num_sp/10+1;
            id_wpn = input_cmqm{idic}.cmcqm_cmaes_it{ids}.num_wpn/10+1;
            cmqm_cmaes_it{id_sp, id_wpn} = input_cmqm{idic}.cmcqm_cmaes_it{ids};
    
        end
    end
end
save tmp\conference_room\cmqm_cmaes_it.mat cmqm_cmaes_it
%%
clearvars -except all_eval;
%%
load tmp\conference_room\cmqm_cmaes_it.mat
%%
for ids = 1:numel(cmqm_cmaes_it)
        if ~isempty(cmqm_cmaes_it{ids})
            cmqm_cmaes_it{ids}.solutions{end-1}.sensors_selected = size(cmqm_cmaes_it{ids}.solutions{end-1}.sp, 2);
            cmqm_cmaes_it{ids}.sol = cmqm_cmaes_it{ids}.solutions{end-1};
            
    %%
            cmqm_cmaes_it{ids}.quality.sum_max = sum(cellfun(@(x) max(x), cmqm_cmaes_it{ids}.sol.quality.wss.val));
            
            cmqm_cmaes_it{ids}.sensors_selected = ones(1, cmqm_cmaes_it{ids}.sol.sensors_selected);
%             cmqm_cmaes_it{ids}.sc_selected = cmqm_cmaes_it{ids}.sol.sc_selected;
            cmqm_cmaes_it{ids}.all_wpn = cmqm_cmaes_it{ids}.sol.discretization.num_positions;
            cmqm_cmaes_it{ids}.all_sp = cmqm_cmaes_it{ids}.sol.discretization.num_sensors;
            
        end
end
%%
save(sprintf('tmp/%s/%s.mat', name, opt_name), opt_name);

%%
input = Experiments.Diss.conference_room(cmqm_cmaes_it{ids}.num_sp, cmqm_cmaes_it{ids}.num_wpn);
cmqm_cmaes_it{ids}.solutions(end) = [];
sol = cmqm_cmaes_it{ids}.solutions{end-1};
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
cmqm_cmaes_it{ids}.solutions{end-1} = sol;
