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

midx = 500:1000:5000;
midy = 500:1000:3000;

[x, y] = meshgrid(midx, midy);

for id = 1:numel(x)
    gridcell = rectAsPolygon([x(id), y(id), 1000, 1000]);
    drawPolygon(gridcell, 'linewidth', 1, 'color', 0.6*ones(1,3));
    drawPoint([3000 1000; 1000 2000; 2000 2000; 3000 2000; 4000 2000], 'marker', 'o', 'color', 'k', 'markersize', 5, 'markerfacecolor', 'k');
end

senorposition = [2750 0];
pixel_fov = 48;
distance = 4000;
pix_offset = 90;
pixfov = circleArcToPolyline([senorposition, distance, pix_offset, pixel_fov], 16);
pixfov = [senorposition;pixfov];
drawPolygon(pixfov, 'color', 'k');
fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.2);

% sensorposition = int64(sensorposition);
roomrev = int64([room;room(1,:)]');
o1rev = int64(fliplr([o1;o1(1,:)]'));
o2rev = int64(fliplr([o2;o2(1,:)]'));
o3rev = int64(fliplr([o3;o3(1,:)]'));
o4rev = int64(fliplr([o4;o4(1,:)]'));
env_int = {roomrev, o1rev, o2rev, o3rev, o4rev};
res = visilibity(senorposition', env_int, 10, 10, 0);
res_vfov = bpolyclip(int64(pixfov'), int64(res{1}), true, 10, 1);
mb.fillPolygon(res_vfov, zeros(1,3), 'facealpha', 0.4);
% mb.drawPoint(res_vfov{1}{1}, 'color', 'k', 'markersize', 5, 'markerfacecolor', 'w');


mb.drawPolygon(env, 'color', 'k', 'linewidth', 2);

%%
matlab2tikz('export/VfovIntersectionInvalidPolygon.tikz', 'parseStrings', false);