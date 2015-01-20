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
% %% TODO CONTINUE HERE
% Optimization.Discrete.Greedy.calc_minq(discretization);
% 
% sensors_selected = [];
% wpn_remaining = double(max(sc_wpn_minq, [], 1));
% vm_tmp = discretization.vm;
% cnt = 0;
% %%
% while any(wpn_remaining > 0)
%     %%
%     sumq = sum(sc_wpn_minq>0, 2);
%     [num_wpn_sc id_sc] = max(sumq);
%         
%     if ~isempty(sensors_selected)
%         % R and S are synonyms for the first and second sensor selection arrays
%         [R ids_R] = sort(sum(vm_tmp(sensors_selected,:), 2), 1, 'descend');
%         ids_R = sensors_selected(ids_R);
%         id_R = 1;
%         idRmax = ids_R(id_R);
%         flt_idRmax = find(any(discretization.sc==uint16(idRmax), 2));
%         [num_wpn_s id_s] = max(sum(sc_wpn_minq(flt_idRmax, :)>0, 2));
%         id_s = flt_idRmax(id_s);
%         %%
%         while id_R+1 <= numel(ids_R) && num_wpn_s < R(id_R+1)
%             id_R = id_R + 1;
%             idRmaxTest = ids_R(id_R);
%             flt_idRmaxTest = find(any(discretization.sc==uint16(idRmaxTest), 2));
%             [num_wpn_s_test id_s_test] = max(sum(sc_wpn_minq(flt_idRmaxTest, :)>0, 2));
%             id_s_test = flt_idRmaxTest(id_s_test);
%             %%
%             if num_wpn_s_test > num_wpn_s
%                 id_s = id_s_test;
%                 num_wpn_s = num_wpn_s_test;
%             end
%         end
%     else
%         num_wpn_s = 0;
%     end
%     
%     if num_wpn_sc > num_wpn_s        
%         sc_sel_id = id_sc;
%     else
%         sc_sel_id = id_s;
%     end
%     sc_selected = discretization.sc(sc_sel_id, :);
%     wpn_covered = sc_wpn_minq(sc_sel_id, :)>0;
%     wpn_remaining = wpn_remaining - wpn_covered;
%     vm_tmp(:, wpn_remaining==0) = 0;
%     sensors_selected = unique([sensors_selected(:); sc_selected(:)]);
%     sc_selected = comb2unique(sensors_selected);
%     %%
%     sc_wpn_minq(sc_selected, :) = 0;
%     sc_wpn_minq(:, wpn_covered) = sc_wpn_minq(:, wpn_covered)-1;
%     %     num_wpn_covered = num_wpn_covered + sum(wpn_ids);
%     cnt = cnt + 1;
% end
% time = toc;
% 
% %% return result in solution form
% sensors_selected = unique(discretization.sc(sc_selected, :));
% solution = DataModels.solution();
% % solution.x = sensors_selected;
% solution.sensors_selected = sensors_selected;
% solution.sc_selected = sc_selected;
% solution.name = config.name;
% solution.solvingtime = time;
% solution.iterations = cnt;
return;
%% TEST
num_wpn = 0;
num_sp = 0;

input = Experiments.Diss.conference_room(num_sp, num_wpn, true);
discretization = input.discretization;
quality = input.quality;
