close all;
clear all;
%%
cla;
axis equal
axis off
xlim([-100 4000]);
ylim([-100 4000]);
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

% matlab2tikz('export/ClassesOfPolygons.tikz')
filename = '../../Dissertation/Thesis/Figures/ClassesOfPolygons.tikz';
matlab2tikz(filename, 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '11cm',...
...    'height', '5cm', 
    'extraAxisOptions',{'y post scale=1'});
stn(filename);