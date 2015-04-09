eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it' 'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd'};
% for ide = 1:numel(eval_names)
%     eval_name = 
%%
optsum = [sum(~isnan(all_eval.conference_room.all_num_sp_selected))
sum(~isnan(all_eval.small_flat.all_num_sp_selected))
sum(~isnan(all_eval.large_flat.all_num_sp_selected))
sum(~isnan(all_eval.office_floor.all_num_sp_selected))];

%%
sum(sum(~cellfun(@isempty, all_eval.conference_room.cmcqm_cmaes_it)))
sum(sum(~cellfun(@isempty, all_eval.small_flat.cmcqm_cmaes_it)))
sum(sum(~cellfun(@isempty, all_eval.large_flat.cmcqm_cmaes_it)))
sum(sum(~cellfun(@isempty, all_eval.office_floor.cmcqm_cmaes_it)))
%%
sum(sum(~cellfun(@isempty, all_eval.conference_room.cmcqm_nonlin_it)))
sum(sum(~cellfun(@isempty, all_eval.small_flat.cmcqm_nonlin_it)))
sum(sum(~cellfun(@isempty, all_eval.large_flat.cmcqm_nonlin_it)))
sum(sum(~cellfun(@isempty, all_eval.office_floor.cmcqm_nonlin_it)))
%%
flt_sol = ~cellfun(@isempty, all_eval.office_floor.bspqm_rpd{1}.solutions);
cellfun(@(x) fprintf('%d %d %s\n',x.part, numel(x.sensors_selected), x.header.solutionStatusString) , all_eval.office_floor.bspqm_rpd{1}.solutions(flt_sol));
cellfun(@(x) fprintf('%d %d %s\n',x.part, numel(x.sensors_selected), x.header.solutionStatusString) , all_eval.office_floor.mspqm_rpd{1}.solutions(flt_sol));

bspqm_s_sel = cellfun(@(x) x.sensors_selected, all_eval.office_floor.bspqm_rpd{1}.solutions(flt_sol), 'uniformoutput', false);
bspqm_s_sel = cell2mat(bspqm_s_sel);
size(bspqm_s_sel)


mspqm_s_sel = cellfun(@(x) x.sensors_selected, all_eval.office_floor.mspqm_rpd{1}.solutions(flt_sol), 'uniformoutput', false);
mspqm_s_sel = cell2mat(mspqm_s_sel);
size(mspqm_s_sel)
%%
bs_nsel = cellfun(@(x) numel(x.sensors_selected) , all_eval.office_floor.bspqm_rpd{1}.solutions(flt_sol));
ms_nsel = cellfun(@(x) numel(x.sensors_selected) , all_eval.office_floor.mspqm_rpd{1}.solutions(flt_sol));


%%
input = Experiments.Diss.office_floor(0, 0);

plot(all_eval.small_flat.all_num_sp_selected(:, [7,8,10]), '.')

nanmean(all_eval.small_flat.all_num_sp_selected(:, [7,8,10]))
%%
fprintf('==================\n');
flt_sol = ~cellfun(@isempty, all_eval.conference_room.bspqm);
cellfun(@(x) fprintf('%d %d %s\n', x.num_sp, x.num_wpn, x.header.solutionStatusString), all_eval.conference_room.bspqm(flt_sol));
fprintf('==================\n');
flt_sol = ~cellfun(@isempty, all_eval.small_flat.bspqm);
cellfun(@(x) fprintf('%d %d %s\n', x.num_sp, x.num_wpn, x.header.solutionStatusString), all_eval.small_flat.bspqm(flt_sol));