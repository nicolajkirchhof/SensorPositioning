close all;
clear all;
%%
cla;
axis equal
hold on;
axis off
xlim([-300 3100]);
ylim([-300 1900]);
omega = 23;
varphi = 10;

wpn = [2500 750];
drawPoint(wpn, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k');
text(2550, 750, '$W_1$');

spn2 = [2250 0];
drawPoint(spn2, 'color', 'k', 'marker', 'o', 'markerfacecolor', 'k');
text(spn2(1)-100, spn2(2)-100, '$S_2$');
drawEdge([spn2 wpn], 'color', 'k');

s2_ang = rad2deg(angle2Points(spn2, wpn));
s1_ang = rad2deg(angle2Points([0,0], wpn));
fov_inner = circleArcToPolyline([wpn, 250, 180+s1_ang, s2_ang-s1_ang], 128);


drawEdge([0, 0, wpn], 'color', 'k');


fov = circleArcToPolyline([0, 0, 3000, varphi, omega], 128);
fov = [0,0;fov];
fillPolygon(fov, 'k', 'facealpha', 0.4);
% drawPolyline(fov);

% x_y = 3000/sqrt(2);
x_y = fov(64, :);
dist = [0,0, x_y];
drawEdge(dist, 'color', 'k', 'linestyle', '-.');

fov_marker = circleArcToPolyline([0, 0, 500, varphi, omega], 128);
drawPolyline(fov_marker, 'color', 'k');
text(500, 300, '$\psi_1$', 'interpreter', 'none');
text(1300, 600, '$d_1$');

fov_target = circleArcToPolyline([0, 0, 750, 0, s1_ang], 128);
drawPolyline(fov_target, 'color', 'k');


phi = circleArcToPolyline([0, 0, 1000, 0, varphi], 128);
x_axis = [0,0,3000, 0];
y_axis = [0,0,0,1800];
drawEdge(x_axis, 'k');
drawEdge(y_axis, 'k');
drawPolyline(phi, 'k');
text(2750, -100, '$x \rightarrow$', 'interpreter', 'none');
text(-200, 1750,  '$\uparrow$ \\ $y$', 'interpreter', 'none');
text(1050, 100,  '$\varphi_1$', 'interpreter', 'none');
text(800, 100,  '$\beta_{1,1}$', 'interpreter', 'none');
text(-200, -100,  '$S_1=(x,y,\varphi)^T$', 'interpreter', 'none');
drawPolyline(fov_inner, 'color', 'k');
text(2100, 500, '$\gamma_{1,2,1}$', 'interpreter', 'none');

plot(0,0, 'marker', 'o', 'markersize', 6, 'markerfacecolor', 'k',  'markeredgecolor', 'k');
%%
filename = 'Sensormodel.tex';
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '6cm',...
    'width', '11cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
Figures.compilePdflatex(filename, true, false);
% Figures.makeFigure('Sensormodel');
% filename = '../../Dissertation/Thesis/Figures/Sensormodel.tikz';
% matlab2tikz(filename, 'parseStrings', false,...
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '11cm',...
% ...    'height', '5cm', 
%     'extraAxisOptions',{'y post scale=1'});
% stn(filename);

% matlab2tikz('export/Sensormodel.tikz', 'parseStrings', false,... 
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-',...
%     'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});

% matlab2tikz('export/Sensormodel.tikz', 'parseStrings', false);
