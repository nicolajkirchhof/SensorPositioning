eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it' 'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd'};
% for ide = 1:numel(eval_names)
%     eval_name = 
%%
optsum = [sum(~isnan(all_eval.conference_room.all_num_sp_selected))
sum(~isnan(all_eval.small_flat.all_num_sp_selected))
sum(~isnan(all_eval.large_flat.all_num_sp_selected))
sum(~isnan(all_eval.office_floor.all_num_sp_selected))];
