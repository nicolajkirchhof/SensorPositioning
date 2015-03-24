%% 
%%
clearvars -except all_eval;
% clearvars -except small_flat conference_room large_flat office_floor
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
ideval = 4;
eval_name = eval_names{ideval};
opts = all_eval.(eval_name);

%%
opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it', 'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd', 'cmcqm_cmaes_it', 'cmcqm_nonlin_it'};
%                  1                 2            3      4       5       6        7        8         9            10           11                 12

opt_name = opt_names{10};
ido = 2601;
ido = 1;
%%
for ide = 1:2
    opt_name = opt_names{ide};
for ido = 1:numel(opts.(opt_name))
    if ~isempty(opts.(opt_name){ido}) 
        opts.(opt_name){ido}.sol = rmfield(opts.(opt_name){ido}.sol,... 
            {'name';'wpn_qualities';'env_qualities';'env_points';'status';'statusstring';'num_sp';'num_wpn'});
    end
end
end
%%%
for ide = 3:5
    opt_name = opt_names{ide};
for ido = 1:numel(opts.(opt_name))
    if ~isempty(opts.(opt_name){ido}) 
        opts.(opt_name){ido} = rmfield(opts.(opt_name){ido},... 
            {'name';'wpn_qualities';'env_qualities';'env_points';'status';'statusstring'});
        
    end
end
end

%%%
for ide = 6:7
    opt_name = opt_names{ide};
for ido = 1:numel(opts.(opt_name))
    if ~isempty(opts.(opt_name){ido}) 
        opts.(opt_name){ido} = rmfield(opts.(opt_name){ido},... 
            {'name';'wpn_qualities';'env_qualities';'env_points';'linearConstraints';'variables';'status';'statusstring'});
        
    end
end
end
%%
for ide = 7
    opt_name = opt_names{ide};
for ido = 1:numel(opts.(opt_name))
    if ~isempty(opts.(opt_name){ido}) 
        opts.(opt_name){ido} = rmfield(opts.(opt_name){ido},... 
            {'num_sensors_additonal';'num_positions_additional'});
        
    end
end
end
%%%
% for ide = 8
%     opt_name = opt_names{ide};
% for ido = 1:numel(opts.(opt_name))
%     if ~isempty(opts.(opt_name){ido}) 
%         opts.(opt_name){ido} = rmfield(opts.(opt_name){ido},... 
%             {'log'});
%         
%     end
% end
% end
%%%
for ide = 9:10
    opt_name = opt_names{ide};
for ido = 1:numel(opts.(opt_name))
    if ~isempty(opts.(opt_name){ido}) 
        for ids = 1:numel(opts.(opt_name){ido}.solutions)
            if ~isempty(opts.(opt_name){ido}.solutions{ids})
                opts.(opt_name){ido}.solutions{ids} = rmfield(opts.(opt_name){ido}.solutions{ids},... 
                    {'name';'status';'statusstring';'num_sp';'num_wpn';'opt_quality';'log'});
            end
        end
    end
end
end

%%
for ide = 1:10
    opt_name = opt_names{ide};
for ido = 1:numel(opts.(opt_name))
    if ~isempty(opts.(opt_name){ido}) 
        disp(ide)
        opts.(opt_name){ido}
        break
    end
end
end
%%
all_eval.(eval_name) = opts;
    