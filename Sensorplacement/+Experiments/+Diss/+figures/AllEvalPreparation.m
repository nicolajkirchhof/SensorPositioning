%
clearvars -except all_eval*;
% clearvars -except small_flat conference_room large_flat office_floor
%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
for ideval = 1:4
    %     ideval = 1;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    %%
    opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it' 'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd'};
    
    num_opts = numel(opt_names);
    all_num_sp_selected= nan(2601, num_opts); %cell(numel(opt_names), 1);
    all_mean_wpn_qualities = nan(2601, num_opts); %zeros(51, 51); %cell(numel(opt_names), 1);
    all_sum_wpn_qualities = nan(2601, num_opts); %zeros(51, 51); %cell(numel(opt_names), 1);
    %%
    for idn = 1:num_opts
        opt_name = opt_names{idn};
        if any(strcmp(fieldnames(opts), opt_name))
            %%
            mean_wpn_qualities = nan(2601,1);
            sum_wpn_qualities = nan(2601,1);
            sp_selected_mat = nan(2601,1);
            opt = opts.(opt_name);
            flt_eval = ~cellfun(@isempty, opt);
            
            num_sp= cellfun(@(x) x.num_sp, opt(flt_eval));
            num_wpn = cellfun(@(x) x.num_wpn, opt(flt_eval));
            
            sp_selected = cellfun(@(x) numel(x.sensors_selected), opt(flt_eval));
            %%
            wpn_qualities = cellfun(@(x) x.quality.sum_max/x.all_wpn, opt(flt_eval));
            ids = sub2ind([51, 51], num_sp/10+1, num_wpn/10+1);
            if idn > 2
                wpn_sum_qualities = cellfun(@(x) x.quality.sum, opt(flt_eval) );
                sum_wpn_qualities(ids) = wpn_sum_qualities;
            end
            
            mean_wpn_qualities(ids) = wpn_qualities;
            
            sp_selected_mat(ids) = sp_selected;
            all_mean_wpn_qualities(:, idn)  = mean_wpn_qualities(:);
            all_sum_wpn_qualities(:, idn)  = sum_wpn_qualities(:);
            all_num_sp_selected(:, idn) = sp_selected_mat(:);
        end
    end
    if ideval == 1
        all_mean_wpn_qualities(:, 9:10) = all_mean_wpn_qualities(:, 7:8);
        all_sum_wpn_qualities(:, 9:10) = all_sum_wpn_qualities(:, 7:8);
        all_num_sp_selected(:, 9:10) = all_num_sp_selected(:, 7:8);
    end
    opts.all_mean_wpn_qualities = all_mean_wpn_qualities;
    opts.all_sum_wpn_qualities = all_sum_wpn_qualities;
    opts.all_num_sp_selected = all_num_sp_selected;
    opts.opt_names = opt_names;
    all_eval.(opts.eval_name) = opts;
end

%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
for ideval = 1:4
    eval_name = eval_names{ideval};
%     opts_cleaned = all_eval_cleaned.(eval_name);
    opts = all_eval.(eval_name);
    opts.all_mean_wpn_qualities = [];
    opts.all_sum_wpn_qualities = [];
    opts.all_num_sp_selected = [];
    opts.all_area_covered_pct = [];
all_eval.(eval_name) = opts;   
end
