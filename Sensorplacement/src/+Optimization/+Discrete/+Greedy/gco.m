function [ solution ] = gco( discretization, quality, config )
%% [ solution ] = gsco( discretization, quality, config )
% uses the greedy combined selection strategy to calculate a min quality
% two coverage
tic;
%%
%     \begin{enumerate}
%     \item calculate the rank for every \ac{sc} as
%     \begin{equation}
%         r_{v}^{sc} = \sum_{j}\aca{m@Qscw}
%     \end{equation}.
%     \item Select the \ac{sc} $v$ with the highest rank.
%     \item Remove all $w_j$ with $\aca{m@Qscw} > 0$ from $W$, which are covered by the \ac{sc}.
%     \item Restart with step 1 if $\vnorm{W} > 0$
%    \end{enumerate}

is_wpn = false(1, discretization.num_positions);
sc_selected = [];
% sc_wpn = discretization.sc_wpn;
cnt = 1;

ids_qvmin = cellfun(@(x) find(x > config.quality.min), quality.wss.val, 'uniformoutput', false);
sc_wpn = false(size(discretization.sc_wpn));
%%
for id = 1:numel(ids_qvmin)
    ids_sc = find(discretization.sc_wpn(:, id));
    sc_wpn(ids_sc(ids_qvmin{id}), id) = true;
end

%%
write_log(' Start calculating gco');
pct = 0;
while ~all(is_wpn)
    %%
    sc_wpn_sum = sum(sc_wpn, 2);
    [val_max, id_max] = max(sc_wpn_sum);
    id_s = discretization.sc(id_max, :);
    is_wpn = is_wpn | discretization.sc_wpn(id_max,:);
    sc_selected = [id_max sc_selected];
    sc_wpn(:, is_wpn) = 0;
    cnt = cnt + 1;
    if round(10*sum(is_wpn)/numel(is_wpn)) > pct
        pct = round(10*sum(is_wpn)/numel(is_wpn));
        write_log('Pct covered = %d\n', pct*10);
    end
end
write_log('Done');
%% return result in solution form
time = toc;
sensors_selected = unique(discretization.sc(sc_selected, :));
solution = DataModels.solution();
% solution.x = sensors_selected;
solution.sensors_selected = sensors_selected;
solution.sc_selected = sc_selected;
solution.name = config.name;
solution.solvingtime = time;
solution.iterations = cnt;
