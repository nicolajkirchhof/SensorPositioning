function draw_vfos(discretization, solution)

%%
h = cellfun(@(x) mb.fillPolygon(x, 'k', 'facealpha', 0.3), discretization.vfovs(solution.sensors_selected));
%%
% arrayfun(@(x) set(x, 'ZData', -ones(size(get(x, 'XData')))), h)