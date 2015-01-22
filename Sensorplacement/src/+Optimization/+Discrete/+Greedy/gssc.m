function [ solution ] = gssc( discretization )
%% [ solution ] = gsco( discretization )
% uses the greedy single sensor selection strategy to calculate a workspace cover
tic;
%%
is_wpn = false(1, discretization.num_positions);
sp_selected = [];
cnt = 1;

vm = discretization.vm;
%%
write_log(' Start calculating gco');
pct = 0;
while ~all(is_wpn)
    %%
    sp_wpn_sum = sum(vm, 2);
    [val_max, id_max] = max(sp_wpn_sum);
    flt_wpn_cov = vm(id_max, :);
    is_wpn = is_wpn | flt_wpn_cov;
    sp_selected = [sp_selected id_max];
    vm(:, is_wpn) = 0;
    cnt = cnt + 1;
    %%
    if round(10*sum(is_wpn)/numel(is_wpn)) > pct
        pct = round(10*sum(is_wpn)/numel(is_wpn));
        write_log('Pct covered = %d\n', pct*10);
    end
end
write_log('Done');
time = toc;
%% return result in solution form
% sensors_selected = unique(discretization.sc(sc_selected, :));
solution = DataModels.solution();
% solution.x = sensors_selected;
solution.sensors_selected =  sp_selected;
solution.sc_selected = [];
solution.name = 'gssc';
solution.solvingtime = time;
solution.iterations = cnt;
