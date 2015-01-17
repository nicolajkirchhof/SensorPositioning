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

drawEdge([0, 0, wpn], 'color', 'k');
text(2000, 500, '$d_{1,1}$');

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
text(600, 350, '$\Omega_1$');
text(1300, 600, '$d_1$');

phi = circleArcToPolyline([0, 0, 1000, 0, varphi], 128);
x_axis = [0,0,3000, 0];
y_axis = [0,0,0,1800];
drawEdge(x_axis, 'k');
drawEdge(y_axis, 'k');
drawPolyline(phi, 'k');
text(2750, -100, '$x \rightarrow$');
text(-200, 1750,  '$\uparrow$ \\ $y$');
text(1050, 100,  '$\varphi$');
text(-200, -100,  '$S_1=(x,y,\varphi)^T$');

plot(0,0, 'marker', 'o', 'markersize', 6, 'markerfacecolor', 'k',  'markeredgecolor', 'k');
%%
filename = '../../Dissertation/Thesis/Figures/Sensormodel.tikz';
matlab2tikz(filename, 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '11cm',...
...    'height', '5cm', 
    'extraAxisOptions',{'y post scale=1'});
stn(filename);

% matlab2tikz('export/Sensormodel.tikz', 'parseStrings', false,... 
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-',...
%     'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});

% matlab2tikz('export/Sensormodel.tikz', 'parseStrings', false);
