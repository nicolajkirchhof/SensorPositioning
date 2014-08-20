close all;
clear all;
%%
cla;
axis equal
hold on;
axis off

xlim([-300 7700]);
ylim([-300 4300]);

senorposition = [1500 0];
drawPoint(senorposition, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k', 'markersize', 5)
pixel_fov = 48;
distance = 4000;
pix_offset = 66;
pixfov = circleArcToPolyline([senorposition, distance, pix_offset, pixel_fov], 16);
pixfov = [senorposition;pixfov];
% drawPolygon(pixfov, 'color', 'k', 'linewidth', 2);
fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);
text(800, -300, '$S_1, S_2$');

senorposition = [1500 0];
drawPoint(senorposition, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k', 'markersize', 5)
pixel_fov = 48;
distance = 4000;
pix_offset = 60;
pixfov = circleArcToPolyline([senorposition, distance, pix_offset, pixel_fov], 16);
pixfov = [senorposition;pixfov];
% drawPolygon(pixfov, 'color', 'k', 'linewidth', 2);
fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);
text(1100, 4300, '$S_3$');

senorposition = [1500 4000];
drawPoint(senorposition, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k', 'markersize', 5)
pixel_fov = 48;
distance = 4000;
pix_offset = 246;
pixfov = circleArcToPolyline([senorposition, distance, pix_offset, pixel_fov], 16);
pixfov = [senorposition;pixfov];
% drawPolygon(pixfov, 'color', 'k', 'linewidth', 2);
fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);


senorposition = [5000 2000];
drawPoint(senorposition, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k', 'markersize', 5)
distance = 1350;
% uncertainty = 300;
uncertainty_circle_middle = circleToPolygon([senorposition, distance], 128);
drawPolygon(uncertainty_circle_middle, 'color', 'k', 'linewidth', 20);
% uncertainty_circle_inner = circleToPolygon([senorposition, distance-uncertainty], 128);
% uncertainty_circle = bpolyclip(uncertainty_circle_outer', uncertainty_circle_inner', 0, true, 0, 1);
% uc = [uncertainty_circle_outer; [nan nan]; uncertainty_circle_inner];
% mb.drawPolygon(uc, 'color', 'k');
% fillPolygon(uc, zeros(1,3), 'facealpha', 0.3);
% fillPolygon(uncertainty_circle_inner, ones(1,3), 'facealpha', 0);
text(4500, 1600, '$S_4 S_5$');

senorposition = [5150 2000];
drawPoint(senorposition, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k', 'markersize', 5)
distance = 1350;
% uncertainty = 300;
uncertainty_circle_middle = circleToPolygon([senorposition, distance], 128);
drawPolygon(uncertainty_circle_middle, 'color', 'k', 'linewidth', 20);
% uncertainty_circle_inner = circleToPolygon([senorposition, distance-uncertainty], 128);
% uncertainty_circle = bpolyclip(uncertainty_circle_outer', uncertainty_circle_inner', 0, true, 0, 1);
% uc = [uncertainty_circle_outer; [nan nan]; uncertainty_circle_inner];
% mb.drawPolygon(uc, 'color', 'k');
% fillPolygon(uc, zeros(1,3), 'facealpha', 0.3);
% fillPolygon(uncertainty_circle_inner, ones(1,3), 'facealpha', 0);

senorposition = [7700 2000];
drawPoint(senorposition, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k', 'markersize', 5)
distance = 1350;
% uncertainty = 300;
uncertainty_circle_middle = circleToPolygon([senorposition, distance], 128);
drawPolygon(uncertainty_circle_middle, 'color', 'k', 'linewidth', 20);
% uncertainty_circle_inner = circleToPolygon([senorposition, distance-uncertainty], 128);
% uncertainty_circle = bpolyclip(uncertainty_circle_outer', uncertainty_circle_inner', 0, true, 0, 1);
% uc = [uncertainty_circle_outer; [nan nan]; uncertainty_circle_inner];
% mb.drawPolygon(uc, 'color', 'k');
% fillPolygon(uc, zeros(1,3), 'facealpha', 0.3);
% fillPolygon(uncertainty_circle_inner, ones(1,3), 'facealpha', 0);
text(7100, 1600, '$S_6$');



%%%
matlab2tikz('export/UncertaintyRegion0vs180deg.tikz', 'parseStrings', false);