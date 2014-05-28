function wss_ustats(q)
cla, hold on;
allvals = 1-cell2mat(q);
groups  = cellfun(@(x,id) ones(size(x))*id, q, num2cell(1:numel(q))', 'uniformoutput', false);
groups = cell2mat(groups);
boxplot(allvals, groups);

% for idw = 1:numel(q)
% 
% %      plot3(ones(size(q{idw}))*idw, 1:numel(q{idw}), q{idw});
% end
% theme(gca, 'office', false);
