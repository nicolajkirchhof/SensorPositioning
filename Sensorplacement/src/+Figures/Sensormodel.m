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
matlab2tikz('export/Sensormodel.tikz', 'parseStrings', false,... 
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-',...
    'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});

% matlab2tikz('export/Sensormodel.tikz', 'parseStrings', false);

%%
return;
ortho = [0 1000 1000 0   0;
        0 0    800  800   0];
      
mb.drawPolygon(ortho, 'color', 'k', 'linewidth', 2);
text(200, -100, 'orthogonal');

radius = 500;
ang = linspace(0, 2*pi, 6)+pi/2;
[px, py] = pol2cart(ang, radius);
convex = bsxfun(@plus, [px;py], [2000;500]);
mb.drawPolygon(convex, 'color', 'k', 'linewidth', 2);
text(1800, -100, 'convex');

radius = 500;
ang = linspace(0, 2*pi, 18);
[pxi, pyi] = pol2cart(ang(1:2:end-1), 250);
[pxo, pyo] = pol2cart(ang(2:2:end), radius);
star = zeros(2, 12);
for i = 1:numel(pxo)
    star(:, 2*i-1) = [pxi(i); pyi(i)];
    star(:, 2*i) = [pxo(i); pyo(i)];
    i = i+1;
end
% star = [star, star(:,1)];
% star = [star, [500; 0]];
star = bsxfun(@plus, star, [3400;500]);
% mb.drawPoint(star)
mb.drawPolygon(star(:,1:end), 'color', 'k', 'linewidth', 2);
text(3050, -100, 'star shaped');

matlab2tikz('export/ClassesOfPolygons.tikz')