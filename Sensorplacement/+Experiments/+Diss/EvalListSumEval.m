%
clearvars -except all_eval*;
% clearvars -except small_flat conference_room large_flat office_floor
%%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
counts = [];

for ideval = 1:4
    %     ideval = 1;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    %%
    continuous = {'cmqm_nonlin_it', 'cmqm_cmaes_it', 'cmcqm_nonlin_it', 'cmcqm_cmaes_it'};
    greedy = {'gco', 'gcss', 'gsss'};
    optims = {'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd' };
    
    for id = 1:numel(continuous)
        opt_name = continuous{id};
        if any(strcmp(fieldnames(opts), opt_name))
        counts.(eval_name).continuous = sum(sum(~(cellfun(@isempty, opts.(opt_name)))));
        end
    end
    
    for id = 1:numel(greedy)
        opt_name = greedy{id};
        if any(strcmp(fieldnames(opts), opt_name))
        counts.(eval_name).greedy = sum(sum(~(cellfun(@isempty, opts.(opt_name)))));
        end
    end
    
    for id = 1:numel(optims)
        opt_name = optims{id};
        if any(strcmp(fieldnames(opts), opt_name))
        counts.(eval_name).optims = sum(sum(~(cellfun(@isempty, opts.(opt_name)))));
        end
    end
    
    
end