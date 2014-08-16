close all;
clear all;
%%
cla;
axis equal
hold on;
axis off

xlim([-300 5300]);
ylim([-300 3300]);

room = rectAsPolygon([2500, 1500, 5000, 3000]);
% room = [0 0; 5000 0; 5000 3000; 0 3000; 0, 0];
o1 = rectAsPolygon([1000, 1000, 200, 1000]);
o2 = rectAsPolygon([2000, 1000, 200, 1000]);
o3 = rectAsPolygon([1500, 2500, 1400, 200]);
o4 = rectAsPolygon([4000, 1000, 1000, 1000]);

env = bpolyclip(room', o1', 0, true);
env = bpolyclip(env, o2', 0, true);
env = bpolyclip(env, o3', 0, true);
env = bpolyclip(env, o4', 0, true);

% legend off
%%%

midx = 500:1000:5000;
midy = 500:1000:3000;

[x, y] = meshgrid(midx, midy);

for id = 1:numel(x)
    gridcell = rectAsPolygon([x(id), y(id), 1000, 1000]);
    drawPolygon(gridcell, 'linewidth', 1, 'color', 0.6*ones(1,3));
    drawPoint([3000 1000; 1000 2000; 2000 2000; 3000 2000; 4000 2000], 'marker', 'o', 'color', 'k', 'markersize', 5, 'markerfacecolor', 'k');
end

mb.drawPolygon(env, 'color', 'k', 'linewidth', 2);


%%
matlab2tikz('export/GbsInRoom.tikz', 'parseStrings', false);