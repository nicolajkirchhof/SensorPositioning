%%
clearvars -except all_eval;
% clearvars -except small_flat conference_room large_flat office_floor
%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
ideval = 1;
eval_name = eval_names{ideval};
opts = all_eval.(eval_name);
% opts.eval_name = eval_name;
% %%
% all_eval.small_flat = small_flat;
% all_eval.conference_room = conference_room;
% all_eval.large_flat = large_flat;
% all_eval.office_floor = office_floor;
% opt_names = fieldnames(opts);
% gray_colorline = linspace(0,0.8,50)';
% gray_colormap = repmat(gray_colorline, 1, 3);
% set(gcf, 'color', [1 1 1]);
%%
opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it' 'gco', 'gcss', 'gsss', 'stcm', 'mspqm'};
opt_names = [opt_names {'bspqm'}];
% opt_names = [opt_names {'mspqm_rpd', 'bspqm_rpd'}];

num_opts = numel(opt_names);
all_num_sp_selected= nan(2601, num_opts); %cell(numel(opt_names), 1);
all_mean_wpn_qualities = nan(2601, num_opts); %zeros(51, 51); %cell(numel(opt_names), 1);
%%%
cnt = 1;
% flt_opt = false(1, numel(opt_names));
for idn = 1:num_opts
    opt_name = opt_names{idn};
%     if ~any(strcmp(opt_name, {'cmcqm_cmaes_it', 'cmcqm_nonlin_it'}))
        %%
        mean_wpn_qualities = nan(2601,1);
        sp_selected_mat = nan(2601,1);
        opt = opts.(opt_name);
        flt_eval = ~cellfun(@isempty, opt);
        
        num_sp= cellfun(@(x) x.num_sp, opt(flt_eval));
        num_wpn = cellfun(@(x) x.num_wpn, opt(flt_eval));
        
        sp_selected = cellfun(@(x) numel(x.sensors_selected), opt(flt_eval));
        %%
        wpn_qualities = cellfun(@(x) x.quality.sum_max/x.all_wpn, opt(flt_eval));
    
        ids = sub2ind([51, 51], num_sp/10+1, num_wpn/10+1);
        mean_wpn_qualities(ids) = wpn_qualities;
        sp_selected_mat(ids) = sp_selected;
        all_mean_wpn_qualities(:, cnt)  = mean_wpn_qualities(:);
        all_num_sp_selected(:, cnt) = sp_selected_mat(:);
%         flt_opt(idn) = true; 
        cnt = cnt+1;
%     end
end
opts.all_mean_wpn_qualities = all_mean_wpn_qualities;
opts.all_num_sp_selected = all_num_sp_selected;
opts.opt_names = opt_names;