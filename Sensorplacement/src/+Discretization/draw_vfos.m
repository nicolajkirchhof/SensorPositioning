function draw_vfos(discretization, solution)

%%
cellfun(@(x) mb.fillPolygon(x, 'k', 'facealpha', 0.3), discretization.vfovs(solution.sensors_selected));
%%
XY = discretization.sp(1:2, solution.sensors_selected);
Z = ones(size(XY, 2), 1);
%%
stem3(XY(1,:)',XY(2,:)',Z, 'color', 'w', 'marker', 'o', 'markerfacecolor', 'w');
%%
fun_draw_poly_w_z = @(p) plot3(p(1,:)', p(2,:)', ones(size(p(1,:)')), 'color', 'w', 'linestyle', ':', 'linewidth', 0.5);
h = cellfun(fun_draw_poly_w_z, discretization.vfovs(solution.sensors_selected));
%%
% delete(h);
% arrayfun(@(x) set(x, 'ZData', -ones(size(get(x, 'XData')))), h)