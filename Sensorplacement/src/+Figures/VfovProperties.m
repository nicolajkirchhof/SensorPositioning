close all;
clear all;
%%
cla;
axis equal
hold on;
axis off
xlim([-300 8600]);
ylim([-300 8300]);

room = [0 0; 8000 0; 8000 7000; 0 7000; 0, 0];
obstacle = flipud([5000 5000; 7500 5000; 7500 6500; 5000 6500; 5000 5000]);

env = bpolyclip(room', obstacle', 0, true);
mb.drawPolygon(env, 'color', 'k', 'linewidth', 2);

pixel_fov = 48;
distance = 4000;
sensor = [];
% sensor = struct('position', [], 'pixelpoly', {}, 'phi_deg', []);
sensor.position = [0 0];
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
sensor.position = [5000 6500];

pixfov = circleArcToPolyline([sensor.position, distance, pix_offset, pixel_fov], 128);
pixfov = [sensor.position;pixfov];
% drawPolygon(pixfov, 'color', 'k');
% fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);
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


%%%


% plot(4100,3200, 'marker', 'o', 'markersize', 8, 'markerfacecolor', 'k',  'markeredgecolor', 'k');
text(8200, 6700, '$\Lambda_6$');

text(3600, 3700, '$\Lambda_5$');
text(3900, 3060, '$\Lambda_4$');
text(4300, 2100, '$\Lambda_3$');
text(4400, 1160, '$\Lambda_2$');
text(4300, 300, '$\Lambda_1$');

%%%
matlab2tikz('export/SensorSampling.tikz', 'parseStrings', false);

