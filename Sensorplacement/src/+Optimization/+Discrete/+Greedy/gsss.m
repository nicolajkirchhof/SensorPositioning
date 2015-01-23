function [ solution ] = gsss( discretization, quality, solution_coverage, config )
%% [ solution ] = gsss( discretization, solution )

timer = tic;

sc = discretization.sc;

sp_selected = solution_coverage.sensors_selected;
flt_selected = ismember(sc(:, 1), sp_selected)&ismember(sc(:,2), sp_selected);
sc_selected = find(flt_selected);

cnt = 1;
ids_qvmin = cellfun(@(x) find(x > config.quality.min), quality.wss.val, 'uniformoutput', false);
sc_wpn = false(size(discretization.sc_wpn));

for id = 1:numel(ids_qvmin)
    ids_sc = find(discretization.sc_wpn(:, id));
    sc_wpn(ids_sc(ids_qvmin{id}), id) = true;
end
%%%
is_wpn = any(sc_wpn(sc_selected,:), 1);
is_sp = false(discretization.num_sensors, 1);
is_sp(sp_selected) = true;
sc_wpn(:, is_wpn) = 0;

% is_wpn = false(1, discretization.num_positions);
%%
write_log(' Start calculating gco');
pct = 0;
cnt = 0;
while ~all(is_wpn)
    %% find next sp to select
    fun_ids_sc_wpn = @(id_sp) find(ismember(sc(:, 1), [id_sp, sp_selected])&ismember(sc(:,2), [id_sp, sp_selected]));
    ids_sp_left = find(~is_sp);
    ids_sc_wpn_cell = arrayfun(fun_ids_sc_wpn, ids_sp_left, 'uniformoutput', false);

    num_wpn_cell = cellfun(@(x) sum(sc_wpn(x, :), 2), ids_sc_wpn_cell, 'uniformoutput', false);        
    flt_nonempty_sp = cellfun(@(x) ~isempty(x), num_wpn_cell);
    ids_sp_left = ids_sp_left(flt_nonempty_sp);
    num_wpn_cell = num_wpn_cell(flt_nonempty_sp);

    [max_wpn, ids_sc_max_wpn] = cellfun(@(x) max(x), num_wpn_cell );

    [all_max, id_all_max] = max(max_wpn);

    id_sc = ids_sc_wpn_cell{id_all_max}(ids_sc_max_wpn(id_all_max));
    sp_selected = [ids_sp_left(id_all_max) sp_selected];

    %% update matrices
    flt_selected = ismember(sc(:, 1), sp_selected)&ismember(sc(:,2), sp_selected);
    sc_selected = find(flt_selected);
    is_wpn = is_wpn | any(sc_wpn(sc_selected,:), 1);
    is_sp(sp_selected) = true;
    sc_wpn(:, is_wpn) = 0;
    %%
    cnt = cnt + 1;
    if round(10*sum(is_wpn)/numel(is_wpn)) > pct
        pct = round(10*sum(is_wpn)/numel(is_wpn));
        write_log('Pct covered = %d\n', pct*10);
    end
end
write_log('Done');
%% return result in solution form
time = toc(timer);
% sensors_selected = unique(discretization.sc(sc_selected, :));
solution = DataModels.solution();
% solution.x = sensors_selected;
solution.sensors_selected = sp_selected;
solution.sc_selected = sc_selected;
solution.name = config.name;
solution.solvingtime = time;
solution.iterations = cnt;





