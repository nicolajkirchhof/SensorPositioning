%%
% load tmp\all_eval
% load tmp\all_eval_ceaned
clearvars -except all_eval*;
% clearvars -except small_flat conference_room large_flat office_floor
%%

eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
%%
cmqm_stat_nonlin_median = nan(1, 4);
cmqm_stat_cmaes_median = nan(1, 4);
for ideval = 1:4
    %%
%     ideval = 3;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    %%%
    flt_nonempty_nonlin = ~cellfun(@isempty, opts.cmqm_nonlin_it);
    cmqm_stat_nonlin_median(ideval) = median(cellfun(@(x) numel(x.solutions)-1,  opts.cmqm_nonlin_it(flt_nonempty_nonlin)));
    
    flt_nonempty_cmaes = ~cellfun(@isempty, opts.cmqm_cmaes_it);
    cmqm_stat_cmaes_median(ideval) = median(cellfun(@(x) numel(x.solutions)-1,  opts.cmqm_cmaes_it(flt_nonempty_cmaes)));
    
    
    
    
    
end
%%
cmcqm_stat_nonlin_median = nan(1, 4);
cmcqm_stat_cmaes_median = nan(1, 4);
for ideval = 1:4
    %%
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    %%%
    flt_nonempty_nonlin = ~cellfun(@isempty, opts.cmcqm_nonlin_it);
    sum(flt_nonempty_nonlin(:))
    cmcqm_stat_nonlin_median(ideval) = median(cellfun(@(x) numel(x.solutions)-1,  opts.cmcqm_nonlin_it(flt_nonempty_nonlin)));
    
    flt_nonempty_cmaes = ~cellfun(@isempty, opts.cmcqm_cmaes_it);
    sum(flt_nonempty_cmaes(:))
    cmcqm_stat_cmaes_median(ideval) = median(cellfun(@(x) numel(x.solutions)-1,  opts.cmcqm_cmaes_it(flt_nonempty_cmaes)));
    
    
    
    
    
end