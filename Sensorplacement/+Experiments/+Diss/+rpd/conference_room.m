%%
clear variables;
% set(gca, 'CameraUpVector', [0 1 0]);

filename = 'res/floorplans/P1-Seminarraum.dxf';

env = Environment.load(filename);
env.obstacles = {};
env_comb = Environment.combine(env);
bpoly = env_comb.combined;
% bpoly = cellfun(@(x) circshift(x, -1, 1), bpoly, 'uniformoutput', false);
num_sp = 0;
num_wpn = 0;
input = Experiments.Diss.conference_room(num_sp, num_wpn);
[P_c, E_r] = mb.polygonConvexDecomposition(bpoly);

parts = Environment.filter(input, P_c);
%%
P_c = cellfun(@(x) mb.visilibity2boost(x), P_c, 'uniformoutput', false);

%%
bspqm_config = Configurations.Optimization.Discrete.bspqm;
bspqm_config.common.workdir = 'tmp/conference_room/bspqm_rdp';

for idpt = 1:numel(parts)
    if parts{idpt}.discretization.num_positions > 0
        filename = Optimization.Discrete.Models.bspqm(parts{idpt}.discretization, parts{idpt}.quality, bspqm_config);
        filename_new = strrep(filename, '.lp', sprintf('p%d.lp', idpt));
        movefile(filename, filename_new);
    end
end


%%
cla;
axis equal
axis off
hold on
fun_draw_edge = @(e) drawEdge(e, 'linewidth', 1, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);

% axis on
ylim([250 3900]);
xlim([1150 8400]);