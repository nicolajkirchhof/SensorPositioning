
input = Experiments.Diss.conference_room(100, 100);
bspqmcr = all_eval.conference_room.bspqm{11, 11};
[~, qbsqmcr] = Evaluation.filter(bspqmcr, input.discretization);
qvalbspqm = cellfun(@sum, qbsqmcr.wss.val);
mspqmcr = all_eval.conference_room.mspqm{11, 11};
[~, qmspqmcr] = Evaluation.filter(mspqmcr, input.discretization);
qvalmspqm = cellfun(@sum, qmspqmcr.wss.val);
fprintf('mspqm qsum %g bspqm qsum %g\n', mspqmcr.quality.sum_max, bspqmcr.quality.sum_max)


clf
hold on
subplot(2, 1, 1)
plot(qvalmspqm, '.', 'color', 0.5*ones(1,3), 'linewidth', 2)
subplot(2, 1, 2)
plot(qvalbspqm, '.', 'color', 0.3*ones(1,3), 'linewidth', 2)
%%
clf
hold on
hist([qvalmspqm, qvalbspqm], 20)% '.', 'color', 0.5*ones(1,3), 'linewidth', 2)
h = findobj(gca,'Type','patch');
xlabel('$\sum_{v, j} \mathbf{Q^\text{scw}}$', 'interpreter', 'none')
ylabel('$\#WPN$', 'interpreter', 'none')
% legend('mspqm','bspqm')
set(h(1), 'facecolor', 0.6*ones(1,3))
set(h(2), 'facecolor', 0.2*ones(1,3))
    filename = sprintf('MspqmVBspqm.tex');
    full_filename = sprintf('export/%s', filename);
    matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '2cm',...
        'width', '10cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    %     find_and_replace(full_filename, 'ylabel={\[\\#\]}', 'ylabel={[\\#SP]},\nevery axis y label/.style={at={(current axis.north west)},anchor=east}');
    %     find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');
    %     find_and_replace(full_filename,'bar\ shift=.\d.\d*cm,', '');
    %     find_and_replace(full_filename,'bar\ shift=\d.\d*cm,', '');
    %     find_and_replace(full_filename,'inner\ sep=0mm', 'inner sep=1pt');
    Figures.compilePdflatex(filename, true, false);
%%
sum(qvalbspqm>3)
sum(qvalmspqm>3)
%%
mean(qvalbspqm)






%%
input = Experiments.Diss.small_flat(100, 100);
bspqmcr = all_eval.small_flat.bspqm{11, 11};
[~, qbsqmcr] = Evaluation.filter(bspqmcr, input.discretization);
qvalbspqm = cellfun(@sum, qbsqmcr.wss.val);
mspqmcr = all_eval.small_flat.mspqm{11, 11};
[~, qmspqmcr] = Evaluation.filter(mspqmcr, input.discretization);
qvalmspqm = cellfun(@sum, qmspqmcr.wss.val);
fprintf('mspqm qsum %g bspqm qsum %g\n', mspqmcr.quality.sum_max, bspqmcr.quality.sum_max)
clf
hold on
subplot(2, 1, 1)
plot(qvalmspqm, '.', 'color', 0.5*ones(1,3), 'linewidth', 2)
subplot(2, 1, 2)
plot(qvalbspqm, '.', 'color', 0.3*ones(1,3), 'linewidth', 2)
%%
clf
hold on
hist([qvalmspqm, qvalbspqm], 20)% '.', 'color', 0.5*ones(1,3), 'linewidth', 2)
h = findobj(gca,'Type','patch');
legend('mspqm','bspqm')
set(h(1), 'facecolor', 0.6*ones(1,3))
set(h(2), 'facecolor', 0.2*ones(1,3))
%%
sum(qvalbspqm>3)
sum(qvalmspqm>3)
hist(qvalbspqm)
%%
mean(qvalbspqm)