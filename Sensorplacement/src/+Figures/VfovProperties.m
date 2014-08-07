close all;
clear all;
%%
cla;
axis equal
hold on;
axis off
xlim([-300 8300]);
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
fov_label = circleArcToPolyline([sensor.position, distance+800, pix_offset, pixel_fov], 128);
drawPolyline(fov_label, 'color', 'k');
%%
% sensor = struct('position', [], 'pixelpoly', {}, 'phi_deg', []);
sensor.position = int64([8000 7000]);

offset = 12;
pix_offset = 180;

% for idpix = 1:4
%     pix_offset = pix_offset+(idpix-1)*offset;
    pixfov = circleArcToPolyline([sensor.position, distance, pix_offset, pixel_fov], 128);
    pixfov = [sensor.position;pixfov];
    drawPolygon(pixfov, 'color', 'k');
    fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);
    fov_label = circleArcToPolyline([sensor.position, distance+200*idpix, pix_offset, pixel_fov], 128);
    drawPolyline(fov_label, 'color', 'k');
% end

% pix_offset = 90-pixel_fov;
% pixfov = circleArcToPolyline([sensor.position, distance, pix_offset, pixel_fov], 128);
% pixfov = [sensor.position;pixfov];
% drawPolygon(pixfov, 'color', 'k');
% fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);
% fov_label = circleArcToPolyline([sensor.position, distance+800, pix_offset, pixel_fov], 128);
% drawPolyline(fov_label, 'color', 'k');

%%
env_1 = int64(room);
res = visilibity([8000; 7000], env_1, 10, 10, 0);


%%
%elevated
distance = 6000;

ids = 1;
idpix = 7;
pix_offset = sensor(ids).phi_deg+(idpix-1)*pixel_fov;
pixfov = circleArcToPolyline([sensor(ids).position, distance, pix_offset, pixel_fov], 128);
pixfov = [sensor(ids).position;pixfov];
drawPolygon(pixfov, 'color', 'k');
fillPolygon(pixfov, 'k', 'facealpha', 0.2);
e1 = pixfov;

ids = 2;
idpix = 10
if idpix <= 8
    pix_offset = sensor(ids).phi_deg+(idpix-1)*pixel_fov;
end
if idpix > 8
    pix_offset = sensor(ids).phi_deg+90-(17-idpix)*pixel_fov;
end
pixfov = circleArcToPolyline([sensor(ids).position, distance, pix_offset, pixel_fov], 128);
pixfov = [sensor(ids).position;pixfov];
drawPolygon(pixfov, 'color', 'k');
fillPolygon(pixfov, 'k', 'facealpha', 0.2);
e2 = pixfov;

ids = 3;
idpix = 8
if idpix <= 8
    pix_offset = sensor(ids).phi_deg+(idpix-1)*pixel_fov;
end
if idpix > 8
    pix_offset = sensor(ids).phi_deg+90-(17-idpix)*pixel_fov;
end
pixfov = circleArcToPolyline([sensor(ids).position, distance, pix_offset, pixel_fov], 128);
pixfov = [sensor(ids).position;pixfov];
drawPolygon(pixfov, 'color', 'k');
fillPolygon(pixfov, 'k', 'facealpha', 0.2);
e3 = pixfov;



plot(4100,3200, 'marker', 'o', 'markersize', 8, 'markerfacecolor', 'k',  'markeredgecolor', 'k');

text(-600, -300, '$S_1$');
text(8000, -300, '$S_2$');
text(8000, 7300, '$S_3$');
text(-600, 7300, '$S_4$');


matlab2tikz('export/ThiloSetup.tikz', 'parseStrings', false);