clearvars -except all_eval*

eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
for ideval = 2:4
    %     ideval = 1;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    
    
    opt_names = {'gco', 'gcss', 'gsss'};
    cnt = 0;
    idsp_range = 1:1:51;
    idwpn_range = 1:1:51;
    loop_display(numel(idsp_range)*numel(idwpn_range), 5);
    inputs = cell(max(idsp_range), max(idwpn_range));
    
    for idsp = idsp_range
        for idwpn = idwpn_range
            inputs{idsp, idwpn} = Experiments.Diss.(eval_name)((idsp-1)*10, (idwpn-1)*10);
            cnt = cnt + 1;
            loop_display(cnt);
        end
    end
    %%
    loop_display(numel(idsp_range)*numel(idwpn_range), 5);
    cnt = 0;
    for ido = 1:numel(opt_names)
        opt_name = opt_names{ido};
        opt_name_it = [opt_name '_it'];
        %%
        opt_it = cell(51, 51);
        for idsp = idsp_range
            for idwpn = idwpn_range
                %%
                opt = opts.(opt_name){idsp, idwpn};
                input = inputs{idsp, idwpn};
                sc = opt.sc_selected;
                sp = opt.sensors_selected;
                qmin = 0.45;
                ids_qvmin = cellfun(@(x) find(x > qmin), input.quality.wss.val, 'uniformoutput', false);
                sc_wpn = false(size(input.discretization.sc_wpn));
                for id = 1:numel(ids_qvmin)
                    ids_sc = find(input.discretization.sc_wpn(:, id));
                    sc_wpn(ids_sc(ids_qvmin{id}), id) = true;
                end
                
                
                all_found = false;
                %%
                while ~(all_found)
                    %%
                    sp_inds = input.discretization.sc(sc, :);
                    sc_lonely = arrayfun(@(x, y) sum(sum([sp_inds==x;sp_inds==y])) <= 2, sp_inds(:,1), sp_inds(:,2));
                    id_scls = find(sc_lonely);
                    %%
                    if ~isempty(id_scls)
                        %%
                        all_visited = isempty(id_scls);
                        while ~all_visited
                            %%
                            id_scl = id_scls(1);
                            sc_lonely_ind = sc(id_scl);
                            wpn_flt = sc_wpn(sc_lonely_ind, :);
                            sc_flt = sc_wpn;
                            sc_flt(:, ~wpn_flt) = 0;
                            repl_find = all(~bsxfun(@xor, sc_flt, wpn_flt), 2);
                            repl_cand = find(repl_find);
                            
                            id_sp_rest = setdiff(sp, sp_inds(id_scl, :));
                            repl_cand_valued = ismember(input.discretization.sc(repl_cand, 1), id_sp_rest)+ismember(input.discretization.sc(repl_cand, 2), id_sp_rest);
                            [vmax, idmax] = max(repl_cand_valued);
                            if vmax > 0
                                id_sc_max = repl_cand(idmax);
                                sc(id_scl) = id_sc_max;
                                sp = unique([id_sp_rest(:)', input.discretization.sc(id_sc_max, :)]);
                                all_visited = true;
                            else
                                id_scls = id_scls(2:end);
                                all_visited = isempty(id_scls);
                                if all_visited
                                    all_found = true;
                                end
                            end
                        end
                    else
                        all_found = true;
                    end
                end
                
                %%
                all_found = false;
                while ~(all_found)
                    %%
                    sp_inds = input.discretization.sc(sc, :);
                    sc_lonely = arrayfun(@(x, y) sum(sum(sp_inds==x))<2|sum(sum(sp_inds==y))<2, sp_inds(:,1), sp_inds(:,2));
                    id_scls = find(sc_lonely);
                    %%
                    if ~isempty(id_scls)
                        %%
                        all_visited = isempty(id_scls);
                        while ~all_visited
                            %%
                            id_scl = id_scls(1);
                            sc_lonely_ind = sc(id_scl);
                            wpn_flt = sc_wpn(sc_lonely_ind, :);
                            sc_flt = sc_wpn;
                            sc_flt(:, ~wpn_flt) = 0;
                            repl_find = all(~bsxfun(@xor, sc_flt, wpn_flt), 2);
                            repl_cand = find(repl_find);
                            
                            sp_ind_flt = [1:id_scl-1, id_scl+1:size(sp_inds, 1)];
                            id_sp_rest = unique(sp_inds(sp_ind_flt, :));
                            repl_cand_valued = ismember(input.discretization.sc(repl_cand, 1), id_sp_rest)+ismember(input.discretization.sc(repl_cand, 2), id_sp_rest);
                            [vmax, idmax] = max(repl_cand_valued);
                            if vmax > 1
                                id_sc_max = repl_cand(idmax);
                                sc(id_scl) = id_sc_max;
                                sp = unique([id_sp_rest(:)', input.discretization.sc(id_sc_max, :)]);
                                all_visited = true;
                            else
                                id_scls = id_scls(2:end);
                                all_visited = isempty(id_scls);
                                if all_visited
                                    all_found = true;
                                end
                            end
                        end
                    else
                        all_found = true;
                    end
                end
                %%
                valid_cmbs_ids = find(ismember(input.discretization.sc(:,1), sp)&ismember(input.discretization.sc(:,2), sp));
                single_cov = sum(sc_wpn(valid_cmbs_ids, :), 1) == 1;
                sc_greedy = [];
                
                while any(single_cov)
                    %%
                    idnext = find(single_cov, 1, 'first');
                    cov_id = find(sc_wpn(valid_cmbs_ids, idnext), 1, 'first');
                    cov_val = sum(sc_wpn(valid_cmbs_ids, idnext));
                    sc_greedy = unique([sc_greedy, valid_cmbs_ids(cov_id)]);
                    single_cov(idnext) = 0;
                end
                
                is_wpn = any(sc_wpn(sc_greedy, :), 1);
                sc_wpn_valid = sc_wpn(valid_cmbs_ids, :);
                sc_wpn_valid(:, is_wpn) = 0;
                while ~all(is_wpn)
                    %%
                    sc_wpn_sum = sum(sc_wpn_valid, 2);
                    [~, id_max] = max(sc_wpn_sum);
                    is_wpn = is_wpn | sc_wpn_valid(id_max,:);
                    sc_greedy = [valid_cmbs_ids(id_max) sc_greedy];
                    sc_wpn_valid(:, is_wpn) = 0;
                end
                %%
                sp_greedy = unique(input.discretization.sc(sc_greedy, :));
                greedy_diff = numel(sp_greedy) - numel(sp);
                if greedy_diff < 0
                    sp = sp_greedy;
                    sc = sc_greedy;
                end
                
                %%
                
                sol = opt;
                sol.sensors_selected = sp;
                sol.sc_selected = sc;
                sol.greedy_diff = greedy_diff;
                
                [d, q] = Evaluation.filter(sol, input.discretization);
                if any(cellfun(@isempty, q.wss.val)) || any(cellfun(@(x) max(x)<0.45, q.wss.val))
                    error('Solution not valid');
                end
                %%
                %             sol.discretization = d;
                %             sol.quality = q;
                sol.quality.sum_max = sum(cellfun(@max, q.wss.val));
                sol.quality.sum = sum(cellfun(@sum, q.wss.val));
                opt_it{idsp, idwpn} = sol;
                loop_display(cnt);
                cnt = cnt +1;
            end
        end
        opts.(opt_name_it) = opt_it;
    end
    %%
    opt_names = {'gco_it', 'gcss_it', 'gsss_it'};
    opts.greedy_it_num_sp_selected = nan(2601, 3);
    opts.greedy_it_quality = nan(2601, 3);
    opts.greedy_it_gdiff = nan(2601, 3);
    
    for ido = 1:numel(opt_names)
        opt_name = opt_names{ido};
        opt = opts.(opt_name);
        flt_eval = ~cellfun(@isempty, opt);
        % all_gco_improved = nan(2601, num_opts); %zeros(51, 51); %cell(numel(opt_names), 1);
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
end
%%
clf

h = plot([sp_selected_mat(flt_eval), all_eval.conference_room.all_num_sp_selected(flt_eval, 3:5)])
set(h(1), 'linestyle', '--', 'marker', 'o');
set(h(2), 'linestyle', '-', 'marker', 'o');
legend sp_sel gco gcss gsss


