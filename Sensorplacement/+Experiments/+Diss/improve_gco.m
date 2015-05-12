% load tmp\all_eval_cleaned.mat
clearvars -except all_eval*

eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
opt_names = {'sco', 'gcss', 'gsss', 'gco'};
% opt_names = {'sco'};
%%
while exist('tmp\conference_room\sco.mat', 'file') == 0
    pause(60)
end
load tmp\conference_room\sco.mat
%%
all_eval.conference_room.sco = sco;

idsp_range = 1:1:51;
idwpn_range = 1:1:51;
loop_display(numel(idsp_range)*numel(idwpn_range), 5);
cnt = 0;
%%%
for ideval = 1
    %     ideval = 1;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    for ido = 1 %:numel(opt_names)
        opt_name = opt_names{ido};
        opt_name_it = [opt_name '_it'];
        opts.(opt_name_it) = cell(51, 51);
    end
    
    %%
    for idsp = idsp_range
        for idwpn = idwpn_range
            %%
            input = Experiments.Diss.(eval_name)((idsp-1)*10, (idwpn-1)*10);
            
            for ido = 1 %:numel(opt_names)
                %%
                opt_name = opt_names{ido};
                opt_name_it = [opt_name '_it'];
                if isempty(opts.(opt_name_it){idsp, idwpn})
                    opt = opts.(opt_name){idsp, idwpn};
                    
                    sol = Optimization.Discrete.Greedy.improve_greedy_it(input, opt);
                    opts.(opt_name_it){idsp, idwpn} = sol;
                end
                loop_display(cnt);
                cnt = cnt +1;
            end
        end
    end
    
    %%
    n_opt = numel(opt_names);
    opts.greedy_it_num_sp_selected = nan(2601, n_opt);
    opts.greedy_it_quality = nan(2601, n_opt);
    opts.greedy_it_gdiff = nan(2601, n_opt);
    
    for ido = 1:numel(opt_names)
        opt_name = opt_names{ido};
        opt_name_it = [opt_name '_it'];
        opt = opts.(opt_name_it);
        flt_eval = ~cellfun(@isempty, opt);
        
        sp_selected_mat = nan(2601,1);
        mean_wpn_qualities = nan(2601,1);
        greedy_diff = nan(2601, 1);
        num_sp= cellfun(@(x) x.num_sp, opt(flt_eval));
        num_wpn = cellfun(@(x) x.num_wpn, opt(flt_eval));
        
        sp_selected = cellfun(@(x) numel(x.sensors_selected), opt(flt_eval));
        greedy_diff_selected = cellfun(@(x) x.greedy_diff, opt(flt_eval));
        %%%
        wpn_qualities = cellfun(@(x) x.quality.sum_max/x.all_wpn, opt(flt_eval));
        ids = sub2ind([51, 51], num_sp/10+1, num_wpn/10+1);
        
        mean_wpn_qualities(ids) = wpn_qualities;
        greedy_diff(ids) = greedy_diff_selected;
        sp_selected_mat(ids) = sp_selected;
        
        opts.greedy_it_num_sp_selected(:, ido) = sp_selected_mat;
        opts.greedy_it_quality(:, ido) = mean_wpn_qualities;
        opts.greedy_it_gdiff(:, ido) = greedy_diff;
        
    end
    %%
    all_eval.(eval_name) = opts;
    save(sprintf('tmp/%s/greedy_it.mat', eval_name), 'opts');
end
%%
clf

h = plot([sp_selected_mat(flt_eval), all_eval.conference_room.all_num_sp_selected(flt_eval, 3:5)])
set(h(1), 'linestyle', '--', 'marker', 'o');
set(h(2), 'linestyle', '-', 'marker', 'o');
legend sp_sel gco gcss gsss


