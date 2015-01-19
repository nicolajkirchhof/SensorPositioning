close all;
clear all;
%%
clear variables;
cla;
axis equal
hold on;
axis off
xlim([-300 7300]);
ylim([-300 4300]);

txt_props = {'horizontalalignment', 'center', 'verticalalignment', 'middle'};

room = [1000 0; 7000 0; 7000 5000; 1000 5000; 1000, 0];
obstacle = flipud([4000 1000; 4200 1000; 4200 2000; 4000 2000; 4000 1000]);
obstacle2 = flipud([5000 2500; 6000 2500; 6000 2700; 5000 2700; 5000 2500]);

env = bpolyclip(room', obstacle', 0, true);
env = bpolyclip(env, obstacle2', 0, true);
mb.drawPolygon(env, 'color', 'k', 'linewidth', 2);

pixel_fov = 48;
distance = 4000;
pix_offset = 66;
sensor.position = [4000 0];

pixfov = circleArcToPolyline([sensor.position, distance, pix_offset, pixel_fov], 16);
pixfov = [sensor.position;pixfov];
drawPolygon(pixfov, 'color', 'k');
fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.2);

sensor.position = int64([4000 0]);
env_1 = int64(room');
env_2 = int64(obstacle');
env_3 = int64(obstacle2');
env_int = {env_1, env_2, env_3};
res = visilibity(double(sensor.position)', env_int, 10, 10, 0);
res_vfov = bpolyclip(int64(pixfov'), int64(res{1}), true, 10, 1);
mb.fillPolygon(res_vfov, zeros(1,3), 'facealpha', 0.4);

sensor.position = [7000 2500];
pix_offset = 156;
pixfov2 = circleArcToPolyline([sensor.position, distance, pix_offset, pixel_fov], 16);
pixfov2 = [sensor.position;pixfov2];
drawPolygon(pixfov2, 'color', 'k');
fillPolygon(pixfov2, zeros(1,3), 'facealpha', 0.2);

%%%
sensor.position = int64(sensor.position);
env_1 = int64(room');
env_2 = int64(obstacle');
env_3 = int64(obstacle2');
env_int = {env_1, env_2, env_3};
res = visilibity([7000; 2500], env_int, 10, 10, 0);
res_vfov = bpolyclip(int64(pixfov2'), int64(res{1}), true, 10, 1);
mb.fillPolygon(res_vfov, zeros(1,3), 'facealpha', 0.4);

cellsz = 1000;
midx = 1500:cellsz:7000;
midy = 500:cellsz:5000;

[x, y] = meshgrid(midx, midy);

for id = 1:numel(x)
    gridcell = rectAsPolygon([x(id), y(id), cellsz, cellsz]);
    drawPolygon(gridcell, 'linewidth', 1, 'color', 0.6*ones(1,3));
%     drawPoint([3000 1000; 1000 2000; 2000 2000; 3000 2000; 4000 2000], 'marker', 'o', 'color', 'k', 'markersize', 5, 'markerfacecolor', 'k');
end

% plot(4100,3200, 'marker', 'o', 'markersize', 8, 'markerfacecolor', 'k',  'markeredgecolor', 'k');
% text(8200, 6700, '$\Lambda_6$');

% text(3600, 3700, '$\Lambda_5$');
% text(3900, 3060, '$\Lambda_4$');
% text(4300, 2100, '$\Lambda_3$');
% text(4400, 1160, '$\Lambda_2$');
% text(4300, 300, '$\Lambda_1$');

%%%
Figures.makeFigure('VfovIntersectionMultipleParts');
% matlab2tikz('export/VfovIntersectionMultipleParts.tikz', 'parseStrings', false,... 
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-',...
%     'extraAxisOptions',{'y post scale=1'});