close all;
clear all;
%%
cla;
axis equal
hold on;
axis off

txt_props = {'horizontalalignment', 'center', 'verticalalignment', 'middle'};

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
text(1100, 4300, '$S_3$', txt_props{:});

senorposition = [1500 4000];
drawPoint(senorposition, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k', 'markersize', 5)
pixel_fov = 48;
distance = 4000;
pix_offset = 246;
pixfov = circleArcToPolyline([senorposition, distance, pix_offset, pixel_fov], 16);
pixfov = [senorposition;pixfov];
% drawPolygon(pixfov, 'color', 'k', 'linewidth', 2);
fillPolygon(pixfov, zeros(1,3), 'facealpha', 0.3);
%%%
senorposition = [5000 2000];
distance = 1350;
uncertainty = 150;
% uncertainty_circle_middle = circleToPolygon([senorposition, distance+10], 128);
drawPoint(senorposition, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k', 'markersize', 5);
uncertainty_circle_outer = circleToPolygon([senorposition, distance+uncertainty], 128);
uncertainty_circle_inner = circleToPolygon([senorposition, distance-uncertainty], 128);
uc_circle = [uncertainty_circle_outer; flipud(uncertainty_circle_inner)];

fillPolygon(uc_circle, 'k', 'facealpha', 0.3);
%%%
senorposition = [5150 2000];
% 
uncertainty_circle_outer = circleToPolygon([senorposition, distance+uncertainty], 128);
uncertainty_circle_inner = circleToPolygon([senorposition, distance-uncertainty], 128);
uc_circle = [uncertainty_circle_outer; flipud(uncertainty_circle_inner)];
fillPolygon(uc_circle, 'k', 'facealpha', 0.3);
ht = text(5000, 1600, '$S_4 S_5$', txt_props{:});

%%%
senorposition = [7700 2000];
drawPoint(senorposition, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k', 'markersize', 5)
uncertainty_circle_outer = circleToPolygon([senorposition, distance+uncertainty], 128);
uncertainty_circle_inner = circleToPolygon([senorposition, distance-uncertainty], 128);
uc_circle = [uncertainty_circle_outer; flipud(uncertainty_circle_inner)];
fillPolygon(uc_circle, 'k', 'facealpha', 0.3);
text(7700, 1600, '$S_6$', txt_props{:});

xlim([-300 7900]);
ylim([-500 4500]);

%%%
Figures.makeFigure('UncertaintyRegion0vs180deg');
