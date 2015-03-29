%
clearvars -except all_eval*;
% clearvars -except small_flat conference_room large_flat office_floor
%%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
[X, Y] = meshgrid(0:10:500, 0:10:500);
subs = [X(:), Y(:)];
opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it', 'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd'};

loop_display(4*size(subs, 1)*10, 5);
cnt = 0;
%%
for ideval = 1:4
    %%
%     ideval = 1;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    opts_cleaned = all_eval_cleaned.(eval_name);
    input = Experiments.Diss.(eval_name)(0, 0);
    for id_int = 1:size(subs, 1)
        
        num_opts = numel(opt_names);
        numsp = subs(id_int, 1);
        numwpn = subs(id_int, 2);
        idsp = numsp/10+1;
        idwpn = numwpn/10+1;
        
        %%
        for idn = 1:num_opts
            %%
            opt_name = opt_names{idn};
            if any(strcmp(fieldnames(opts), opt_name)) && idsp <= size(opts.(opt_name), 1) ...
                    && idwpn <= size(opts.(opt_name), 2)
            opt =  opts.(opt_name){idsp, idwpn};
            opt_cleaned = opts_cleaned.(opt_name){idsp, idwpn};
            %%
            if ~isempty(opt)
                %%
                if idn < 3
                    sp = opt.sol.sp;
                else
                    sp = opt.discretization.sp;
                end
                opt_prep = Optimization.Continuous.prepare_opt(input, sp);
                qualityarea = (0.9-Optimization.Continuous.fitfct.cmcqm_nostat(opt_prep))*100;
                opt.quality.area_covered = qualityarea;
                opt_cleaned.quality.area_covered = qualityarea;
                opts.(opt_name){idsp, idwpn} = opt;
                opts_cleaned.(opt_name){idsp, idwpn} = opt_cleaned;
            end
            
            end
            cnt = cnt+1;
            loop_display(cnt);
        end
        
    end
    all_eval.(eval_name) = opts;
    all_eval_cleaned.(eval_name) = opts_cleaned;
    
end
%%
for ideval = 1:4
    %%
%     ideval = 1;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    opts_cleaned = all_eval_cleaned.(eval_name);
    for id_int = 1:size(subs, 1)
        
        num_opts = numel(opt_names);
        numsp = subs(id_int, 1);
        numwpn = subs(id_int, 2);
        idsp = numsp/10+1;
        idwpn = numwpn/10+1;
        
        %%
        for idn = 1:num_opts
            %%
            opt_name = opt_names{idn};
            if any(strcmp(fieldnames(opts), opt_name)) && idsp <= size(opts.(opt_name), 1) ...
                    && idwpn <= size(opts.(opt_name), 2)
            opt =  opts.(opt_name){idsp, idwpn};
            opt_cleaned = opts_cleaned.(opt_name){idsp, idwpn};
            %%
            if ~isempty(opt)
                qualityarea = opt.quality.area_covered;
                opt_cleaned.quality.area_covered = qualityarea;
                opts_cleaned.(opt_name){idsp, idwpn} = opt_cleaned;
            end
            
            end
            cnt = cnt+1;
            loop_display(cnt);
        end
        
    end
    all_eval.(eval_name) = opts;
    all_eval_cleaned.(eval_name) = opts_cleaned;
    
end


%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
for ideval = 1:4
    %     ideval = 1;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    opts_cleaned = all_eval_cleaned.(eval_name);
    %%
    opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it' 'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd'};
    
    num_opts = numel(opt_names);

    all_area_covered_pct = nan(2601, num_opts); %zeros(51, 51); %cell(numel(opt_names), 1);
    %%
    for idn = 1:num_opts
        opt_name = opt_names{idn};
        if any(strcmp(fieldnames(opts), opt_name))
            %%
            area_covered_pct = nan(2601,1);
            
%             opt_cleaned = opts_cleaned.(opt_name);
            opt = opts.(opt_name);
            flt_eval = ~cellfun(@isempty, opt);
            
            num_sp= cellfun(@(x) x.num_sp, opt(flt_eval));
            num_wpn = cellfun(@(x) x.num_wpn, opt(flt_eval));
            
            sp_selected = cellfun(@(x) numel(x.sensors_selected), opt(flt_eval));
            area_covered = cellfun(@(x) x.quality.area_covered, opt(flt_eval));
                        
            ids = sub2ind([51, 51], num_sp/10+1, num_wpn/10+1);
            area_covered_mat = nan(51, 51);
            area_covered_mat(ids) = area_covered;
            all_area_covered_pct(:, idn)  = area_covered_mat(:);
        end
    end
%     if ideval == 1
%         all_area_covered_pct(:, 9:10) = all_area_covered_pct(:, 7:8);
%         all_sum_wpn_qualities(:, 9:10) = all_sum_wpn_qualities(:, 7:8);
%         all_num_sp_selected(:, 9:10) = all_num_sp_selected(:, 7:8);
%     end
    opts.all_area_covered_pct = all_area_covered_pct;
    opts_cleaned.all_area_covered_pct = all_area_covered_pct;
    all_eval.(opts.eval_name) = opts;
    all_eval_cleaned.(opts.eval_name) = opts_cleaned;
end