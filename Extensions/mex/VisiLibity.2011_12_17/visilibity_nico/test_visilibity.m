%%%%%%%%%%%%%%%%%%%%%%%%% TEST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load testcase1
vis_polies = visilibity(testpoints, testpoly, 1);



%%%%%%%%%%%%%%%%%%%%%%%%% TEST %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% testing functionality of visilibity
run c:\users\nico\workspace\tools.common\lib\matlab\matgeom.m

env = read_vertices_from_file('example1.environment');

fun_convert_ring2boost = @(x) int64([x', x(1,:)']*1000);
benv = cellfun(fun_convert_ring2boost, env, 'uniformoutput', false);

%%
vis_polys = visilibity(env{1}'*1000, benv, 1);
%%
colors = hsv(numel(vis_polys));
cla; hold on;
for idx_vp = 1:numel(vis_polys)
    drawPolygon(vis_polys{idx_vp}', 'color', colors(idx_vp, :));
    fillPolygon(vis_polys{idx_vp}', colors(idx_vp, :), 'facealpha', 0.1);
end