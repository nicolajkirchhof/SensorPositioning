%%
opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it'};% , 'cmqm_nonlin_it', 'cmqm_cmaes_it'};

loop_display(numel(opt_names)*51*51, 2);
% opt = opts.(opt_name);
cnt = 0;
for ido = 1:numel(opt_names)
    name = opt_names{ido};
    for idoe = 1:numel(small_flat.(name))
        if ~isempty(small_flat.(name){idoe}) 
%        opt{ido}.sensors_selected = opt{ido}.sol.sensors_selected;
            small_flat.(name){idoe}.quality.sum_max = sum(cellfun(@(x) max(x), small_flat.(name){idoe}.sol.quality.wss.val));
            small_flat.(name){idoe}.sensors_selected = small_flat.(name){idoe}.sol.sensors_selected;
            small_flat.(name){idoe}.sc_selected = small_flat.(name){idoe}.sol.sc_selected;
            small_flat.(name){idoe}.all_wpn = small_flat.(name){idoe}.sol.discretization.num_positions;
            small_flat.(name){idoe}.all_sp = small_flat.(name){idoe}.sol.discretization.num_sensors;
        end
        cnt = cnt + 1;
        loop_display(cnt);
    end
end
%%
opt_names = {'gco', 'gcss', 'gsss', 'mspqm', 'bspqm', 'stcm'}; % , 'cmqm_nonlin_it', 'cmqm_cmaes_it'};
% opt_names = {'mspqm_rpd', 'bspqm_rpd'};
loop_display(numel(opt_names)*51*51, 5);
% opt = opts.(opt_name);
cnt = 0;
for ido = 1:numel(opt_names)
    name = opt_names{ido};
    for idoe = 1:numel(small_flat.(name))
        if ~isempty(small_flat.(name){idoe}) 
%        opt{ido}.sensors_selected = opt{ido}.sol.sensors_selected;
            small_flat.(name){idoe}.quality.sum_max = sum(cellfun(@(x) max(x), small_flat.(name){idoe}.quality.wss.val));
            small_flat.(name){idoe}.all_wpn = small_flat.(name){idoe}.discretization.num_positions;
            small_flat.(name){idoe}.all_sp = small_flat.(name){idoe}.discretization.num_sensors;
        end
        cnt = cnt + 1;
        loop_display(cnt);
    end
end
%%
opt_names = {'mspqm_rpd', 'bspqm_rpd'}; % , 'cmqm_nonlin_it', 'cmqm_cmaes_it'};

loop_display(numel(opt_names)*51*51, 5);
% opt = opts.(opt_name);
cnt = 0;
for ido = 1:numel(opt_names)
    name = opt_names{ido};
    for idoe = 1:numel(small_flat.(name))
        if ~isempty(small_flat.(name){idoe}) 
            %%
            small_flat.(name){idoe}.num_sp = small_flat.mspqm_rpd{idoe}.solutions{1}.num_sp;
            small_flat.(name){idoe}.num_wpn = small_flat.mspqm_rpd{idoe}.solutions{1}.num_wpn;
            input = Experiments.Diss.small_flat(small_flat.(name){idoe}.num_sp, small_flat.(name){idoe}.num_wpn);
            [small_flat.(name){idoe}.discretization, small_flat.(name){idoe}.quality] = Evaluation.filter(small_flat.(name){idoe}, input.discretization, Configurations.Quality.diss);
            small_flat.(name){idoe}.quality.sum_max = sum(cellfun(@(x) max(x), small_flat.(name){idoe}.quality.wss.val));
            small_flat.(name){idoe}.all_wpn = small_flat.(name){idoe}.discretization.num_positions;
            small_flat.(name){idoe}.all_sp = small_flat.(name){idoe}.discretization.num_sensors;
        end
        cnt = cnt + 1;
        loop_display(cnt);
    end
end
