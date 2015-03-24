%%
opt_names_include = {'cmqm_nonlin_it', 'cmqm_cmaes_it'};% , 'cmqm_nonlin_it', 'cmqm_cmaes_it'};

loop_display(numel(opt_names_include)*51*51, 2);
% opt = opts.(opt_name);
cnt = 0;
for ido = 1:numel(opt_names_include)
    name = opt_names_include{ido};
    for idoe = 1:numel(opts.(name))
        if ~isempty(opts.(name){idoe}) 
%        opt{ido}.sensors_selected = opt{ido}.sol.sensors_selected;
            opts.(name){idoe}.quality.sum_max = sum(cellfun(@(x) max(x), opts.(name){idoe}.sol.quality.wss.val));
            opts.(name){idoe}.sensors_selected = opts.(name){idoe}.sol.sensors_selected;
            opts.(name){idoe}.sc_selected = opts.(name){idoe}.sol.sc_selected;
            opts.(name){idoe}.all_wpn = opts.(name){idoe}.sol.discretization.num_positions;
            opts.(name){idoe}.all_sp = opts.(name){idoe}.sol.discretization.num_sensors;
        end
        cnt = cnt + 1;
        loop_display(cnt);
    end
end
%%
opt_names_include = {'gco', 'gcss', 'gsss', 'mspqm', 'bspqm', 'stcm'}; % , 'cmqm_nonlin_it', 'cmqm_cmaes_it'};
% opt_names = {'mspqm_rpd', 'bspqm_rpd'};
loop_display(numel(opt_names_include)*51*51, 5);
% opt = opts.(opt_name);
cnt = 0;
for ido = 1:numel(opt_names_include)
    name = opt_names_include{ido};
    for idoe = 1:numel(opts.(name))
        if ~isempty(opts.(name){idoe}) 
%        opt{ido}.sensors_selected = opt{ido}.sol.sensors_selected;
            opts.(name){idoe}.quality.sum_max = sum(cellfun(@(x) max(x), opts.(name){idoe}.quality.wss.val));
            opts.(name){idoe}.all_wpn = opts.(name){idoe}.discretization.num_positions;
            opts.(name){idoe}.all_sp = opts.(name){idoe}.discretization.num_sensors;
        end
        cnt = cnt + 1;
        loop_display(cnt);
    end
end
%%
opt_names_include = {'mspqm'}; % , 'cmqm_nonlin_it', 'cmqm_cmaes_it'};
% opt_names = {'mspqm_rpd', 'bspqm_rpd'};
loop_display(numel(opt_names_include)*51*51, 5);
% opt = opts.(opt_name);
cnt = 0;
for ido = 1:numel(opt_names_include)
    name = opt_names_include{ido};
    for idoe = 1:numel(opts.(name))
        if ~isempty(opts.(name){idoe}) 
%        opt{ido}.sensors_selected = opt{ido}.sol.sensors_selected;
%             opts.(name){idoe}.quality.sum_max = sum(cellfun(@(x) max(x), opts.(name){idoe}.quality.wss.val));
            opts.(name){idoe}.num_sp = opts.(name){idoe}.num_sensors_additonal;
            opts.(name){idoe}.num_wpn = opts.(name){idoe}.num_positions_additional;
%              opts.(name){idoe} = rmfield(opts.(name){idoe}, {'wpn_qualities'; 'env_qualities'
        end
        cnt = cnt + 1;
        loop_display(cnt);
    end
end

%%
opt_names_include = {'mspqm_rpd', 'bspqm_rpd'}; % , 'cmqm_nonlin_it', 'cmqm_cmaes_it'};
eval_name = 'office_floor';
loop_display(numel(opt_names_include)*51*51, 5);
% opt = opts.(opt_name);
cnt = 0;
for ido = 1:numel(opt_names_include)
    name = opt_names_include{ido};
    for idoe = 1:numel(opts.(name))
        if ~isempty(opts.(name){idoe}) 
            %%
            opts.(name){idoe}.num_sp = opts.mspqm_rpd{idoe}.solutions{1}.num_sp;
            opts.(name){idoe}.num_wpn = opts.mspqm_rpd{idoe}.solutions{1}.num_wpn;
            input = Experiments.Diss.(eval_name)(opts.(name){idoe}.num_sp, opts.(name){idoe}.num_wpn);
            [opts.(name){idoe}.discretization, opts.(name){idoe}.quality] = Evaluation.filter(opts.(name){idoe}, input.discretization, Configurations.Quality.diss);
            opts.(name){idoe}.quality.sum_max = sum(cellfun(@(x) max(x), opts.(name){idoe}.quality.wss.val));
            opts.(name){idoe}.all_wpn = opts.(name){idoe}.discretization.num_positions;
            opts.(name){idoe}.all_sp = opts.(name){idoe}.discretization.num_sensors;
        end
        cnt = cnt + 1;
        loop_display(cnt);
    end
end
