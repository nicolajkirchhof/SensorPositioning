function sol = improve_greedy_it(input, opt)

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
