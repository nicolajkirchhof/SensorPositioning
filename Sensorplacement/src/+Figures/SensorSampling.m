close all;
clearvars -except all_eval*;
%%%
cla;
hold on;
axis off


txt_props = {'horizontalalignment', 'center', 'verticalalignment', 'middle'};

room = [0 0; 10000 0; 10000 6000; 0 6000; 0, 0];
obstacle = flipud([6000 4000; 7500 4000; 7500 5000; 6000 5000; 6000 4000]);

env = bpolyclip(room', obstacle', 0, true);
mb.drawPolygon(env, 'color', 'k', 'linewidth', 2);
mb.fillPolygon(obstacle, 0.2*ones(1,3), 'linewidth', 2);

pixel_fov = 48;
distance = 4000;
sensor = [];
% sensor = struct('position', [], 'pixelpoly', {}, 'phi_deg', []);
sensor.position = [0 0];
drawPoint(sensor.position, 'color', 'k', 'marker', 'o', 'markersize', 6, 'linewidth', 2);
offset = 12;

for idpix = 1:4
    pix_offset = (idpix-1)*offset;
    pixfov = circleArcToPolyline([sensor.position, distance, pix_offset, pixel_fov], 128);
    pixfov = [sensor.position;pixfov];
    drawPolygon(pixfov, 'color', 'k');
    fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);
    fov_label = circleArcToPolyline([sensor.position, distance+200*idpix, pix_offset, pixel_fov], 128);
    drawPolyline(fov_label, 'color', 'k');
end

pix_offset = 90-pixel_fov;
pixfov = circleArcToPolyline([sensor.position, distance, pix_offset, pixel_fov], 128);
pixfov = [sensor.position;pixfov];
drawPolygon(pixfov, 'color', 'k');
fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);
fov_label = circleArcToPolyline([sensor.position, distance+1000, pix_offset, pixel_fov], 128);
drawPolyline(fov_label, 'color', 'k');
%%%
pix_offset = 0;
sensor.position = [6000 5000];
drawPoint(sensor.position, 'color', 'k', 'marker', 'o', 'markersize', 6, 'linewidth', 2);

pixfov = circleArcToPolyline([sensor.position, distance, pix_offset, pixel_fov], 128);
pixfov = [sensor.position;pixfov];
pixfov = bpolyclip(int64(room'), int64(pixfov'), 1, true);
pixfov = pixfov{1}{1}';
drawPolygon(pixfov, 'color', 'k');
fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);
fov_label = circleArcToPolyline([sensor.position, distance+200, pix_offset, pixel_fov], 128);
% drawPolyline(fov_label, 'color', 'k');

%%%
sensor.position = int64([8000 7000]);
env_1 = int64(room');
env_2 = int64(obstacle');
env_int = {env_1, env_2};
res = visilibity([8000; 7000], env_int, 10, 10, 0);
res_vfov = bpolyclip(int64(pixfov'), int64(res{1}), true, 10, 1);
mb.fillPolygon(res_vfov, zeros(1,3), 'facealpha', 0.8);
%  plot(4100,3200, 'marker', 'o', 'markersize', 8, 'markerfacecolor', 'k',  'markeredgecolor', 'k');
text(8500, 4600, '$\Lambda_6$', txt_props{:});
text(3800, 3700, '$\Lambda_5$', txt_props{:});
text(4100, 3060, '$\Lambda_4$', txt_props{:});
text(4500, 2150, '$\Lambda_3$', txt_props{:});
text(4600, 1160, '$\Lambda_2$', txt_props{:});
text(4600, 300, '$\Lambda_1$', txt_props{:});

axis equal
%%%
% Figures.makeFigure('SensorSampling');
% matlab2tikz('export/SensorSampling.tikz', 'parseStrings', false);
% xlim([-300 8600]);
% ylim([-300 8300]);
filename = 'SensorSampling.tex';
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
...    'height', '6cm',...
    'width', '11cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);

Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);
