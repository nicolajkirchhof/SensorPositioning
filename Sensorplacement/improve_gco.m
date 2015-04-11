gco = all_eval.conference_room.gco{1};
input = Experiments.Diss.conference_room(0, 0);
%%
loop_display(25, 5);
gco_it = cell(51, 51);
cnt = 0;
for idsp = 1:5:21
    for idwpn = 1:5:21
        
        gco = all_eval.conference_room.gco{idsp, idwpn};
        input = Experiments.Diss.conference_room((idsp-1)*10, (idwpn-1)*10);
        sc = gco.sc_selected;
        sp = gco.sensors_selected;
        
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
                    wpn_flt = input.discretization.sc_wpn(sc_lonely_ind, :);
                    sc_flt = input.discretization.sc_wpn;
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
        %%
        while ~(all_found)
            %%
            sp_inds = input.discretization.sc(sc, :);
            sc_lonely = arrayfun(@(x, y) sum(sum([sp_inds==x;sp_inds==y])) <= 4, sp_inds(:,1), sp_inds(:,2));
            id_scls = find(sc_lonely);
            %%
            if ~isempty(id_scls)
                %%
                all_visited = isempty(id_scls);
                while ~all_visited
                    %%
                    id_scl = id_scls(1);
                    sc_lonely_ind = sc(id_scl);
                    wpn_flt = input.discretization.sc_wpn(sc_lonely_ind, :);
                    sc_flt = input.discretization.sc_wpn;
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
        
        sol = gco;
        sol.sensors_selected = sp;
        sol.sc_selected = sc;
        
        [d, q] = Evaluation.filter(sol, input.discretization);
        
        sol.discretization = d;
        sol.quality = q;
        gco_it{idsp, idwpn} = sol;
        loop_display(cnt);
        cnt = cnt +1;
    end;
end