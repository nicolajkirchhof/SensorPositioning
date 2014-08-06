close all;
clear all;
%%
cla;
axis equal
hold on;
axis off
xlim([-300 3000]);
ylim([-300 3000]);

fov = circleArcToPolyline([0, 0, 3000, 23, 45], 128);
fov = [0,0;fov];
fillPolygon(fov, 0.5*ones(1,3));
% drawPolyline(fov);

x_y = 3000/sqrt(2);
dist = [0,0, x_y, x_y];
drawEdge(dist, 'color', 'k', 'linestyle', '-.');

fov_marker = circleArcToPolyline([0, 0, 500, 23, 45], 128);
drawPolyline(fov_marker, 'color', 'k');
text(450, 350, '$\Lambda_1$');
text(1300, 1500, '$d_1$');

phi = circleArcToPolyline([0, 0, 1000, 0, 23], 128);
x_axis = [0,0,3000, 0];
y_axis = [0,0,0,3000];
drawEdge(x_axis, 'k');
drawEdge(y_axis, 'k');
drawPolyline(phi, 'k');
text(2750, -100, '$x \rightarrow$');
text(-200, 2750,  '$\uparrow$ \\ $y$');
text(1050, 200,  '$\varphi$');
text(-200, -100,  '$S_1=\vmatrix{x\\y\\\phi}$');

plot(0,0, 'marker', 'o', 'markersize', 6, 'markerfacecolor', 'k',  'markeredgecolor', 'k');

matlab2tikz('export/Sensormodel.tikz', 'parseStrings', false);
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