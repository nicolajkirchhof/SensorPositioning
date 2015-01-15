function boxplot(wss)

val = wss.val;
%
% valbw = pc.quality.(name).valbw;
%%
figure, sz = {2, 1};
allvals = cell2mat(val);

groups  = cellfun(@(x,id) ones(size(x))*id, val, num2cell(1:numel(val))', 'uniformoutput', false);
groups = cell2mat(groups);
% valnan = val;
% valnan(isinf(val(:))) = nan; 
subplot(sz{:}, 1);
boxplot(allvals, groups);
subplot(sz{:}, 2);
% valzero = valnan;
% valzero(isnan(valnan(:))) = 0;
% rowscale = sum(valzero, 2);
valscaled = cell2mat(cellfun(@(x) x./sum(x), val, 'uniformoutput', false));
boxplot(valscaled', groups);

% 
% subplot(sz{:}, 1);
% boxplot(allvals, groups);
% subplot(sz{:},2);
% bar(valbw); hold on;
% line([1 numel(valbw)], [max(valbw); max(valbw)],  'color', 'r');
% subplot(sz{:},3);
% sumvals = cellfun(@sum, val);
% bar(sumvals); hold on;
% line([1 numel(sumvals)], [max(sumvals); max(sumvals)], 'color', 'r');
% subplot(sz{:},4);
% title('scaled values');
% scaledgroups = cellfun(@(x) x/(max(sumvals)+max(valbw)), val, 'uniformoutput', false);
% scaledvals = cell2mat(scaledgroups);
% boxplot(scaledvals, groups);
% subplot(sz{:},5);
% title('sum scaled');
% scaledvals = cellfun(@sum ,scaledgroups);
% bar(scaledvals);
% subplot(sz{:},4);
% title('scaled values');
% scaledvals = cell2mat(cellfun(@(x,id) x./valbw(logical(pc.problem.wp_sc_idx(:,id))), val, num2cell(1:numel(val))', 'uniformoutput', false));
% boxplot(scaledvals, groups);

% for idw = 1:numel(q)
% 
% %      plot3(ones(size(q{idw}))*idw, 1:numel(q{idw}), q{idw});
% end
% theme(gca, 'office', false);
