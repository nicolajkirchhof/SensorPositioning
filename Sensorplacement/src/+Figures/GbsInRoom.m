close all;
clear all;
%%
cla;
axis equal
hold on;
axis off

xlim([-300 5300]);
ylim([-300 3300]);

room = rectAsPolygon([2500, 1500, 5000, 3000]);
% room = [0 0; 5000 0; 5000 3000; 0 3000; 0, 0];
o1 = rectAsPolygon([1000, 1000, 200, 1000]);
fillPolygon(o1, 0.2*ones(1,3));
o2 = rectAsPolygon([2000, 1000, 200, 1000]);
fillPolygon(o2, 0.2*ones(1,3));
o3 = rectAsPolygon([1500, 2500, 1400, 200]);
fillPolygon(o3, 0.2*ones(1,3));
o4 = rectAsPolygon([4000, 1000, 1000, 1000]);
fillPolygon(o4, 0.2*ones(1,3));

env = bpolyclip(room', o1', 0, true);
env = bpolyclip(env, o2', 0, true);
env = bpolyclip(env, o3', 0, true);
env = bpolyclip(env, o4', 0, true);

% legend off
%%%

midx = 500:1000:5000;
midy = 500:1000:3000;

[x, y] = meshgrid(midx, midy);

for id = 1:numel(x)
    gridcell = rectAsPolygon([x(id), y(id), 1000, 1000]);
    drawPolygon(gridcell, 'linewidth', 1, 'color', 0.6*ones(1,3));
    drawPoint([3000 1000; 1000 2000; 2000 2000; 3000 2000; 4000 2000], 'marker', '.', 'color', 'k', 'markersize', 14);
end

mb.drawPolygon(env, 'color', 'k', 'linewidth', 2);
filename = 'GbsInRoom.tex';
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '6cm',...
    'width', '11cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);

Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);

%%
% matlab2tikz('export/GbsInRoom.tikz', 'parseStrings', false);
% filename = 'export/GbsInRoom.tikz';
% matlab2tikz(filename, 'parseStrings', false,...
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '11cm',...
% ...    'height', '5cm', 
%     'extraAxisOptions',{'y post scale=1'});
% stn(filename);
