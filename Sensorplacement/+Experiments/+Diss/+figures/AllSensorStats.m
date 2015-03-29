%% Draw All evaluation Properties
%%
clearvars -except all_eval;
% clearvars -except small_flat conference_room large_flat office_floor
%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
outdir = '..\..\Dissertation\thesis\figures\';
% opt_names = {'CMQM\\(NL)', 'CMQM\\(CMAES)', 'GCO', 'GCSS', 'GSSS', 'STCM', 'MSPQM', 'BSPQM', 'RPD\\(MSPQM)', 'RPD\\(BSPQM)'};
opt_names = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'};

for ideval = 1:numel(eval_names)
%%
% ideval = 1;
eval_name = eval_names{ideval};
opts = all_eval.(eval_name);

plot(opts.all_num_sp_selected(:, [1:5 7:10]), '.');

end