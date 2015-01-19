close all;
clear all;
%%
cla;
axis equal
hold on;
axis off
xlim([0 5000]);
ylim([0 4000]);

x = 250;
y = 1000;
mergeable = [x y; x+250 y+2000; x+500 y];
drawPoint(mergeable, 'marker', 'o', 'markerfacecolor', 'k', 'color', 'k', 'linewidth', 2, 'markeredgecolor', 'k');
drawPolyline(mergeable, 'color', 'k', 'linewidth', 1);
in_edge = [x+500 y-750 x+500 y];
out_edge = [x y-750 x y];
drawEdge(in_edge, 'color', 'k', 'linestyle', ':');
drawEdge(out_edge, 'color', 'k', 'linestyle', ':');
text(125, 3500, 'Mergeable');

separator = [1500 0 1500 4000];
drawEdge(separator, 'color', 'k', 'linewidth', 2);

x = 2250;

left_oriented = [x y+1000; x+250 y+2000; x+500 y];
drawPoint(left_oriented, 'marker', 'o', 'markerfacecolor', 'k', 'color', 'k', 'linewidth', 2, 'markeredgecolor', 'k');
drawPolyline(left_oriented, 'color', 'k', 'linewidth', 1);
in_edge = [x y+1000 x y-750];
out_edge = [x+500 y x+500 y-750];
drawEdge(in_edge, 'color', 'k', 'linestyle', ':');
drawEdge(out_edge, 'color', 'k', 'linestyle', ':');
text(x, 3750, 'Left');
text(x, 3500, 'oriented');

separator = [3500 0 3500 4000];
drawEdge(separator, 'color', 'k', 'linewidth', 2);

x= 4250;

left_oriented = [x+500 2000; x+250 3000; x 1000];
drawPoint(left_oriented, 'marker', 'o', 'markerfacecolor', 'k', 'color', 'k', 'linewidth', 2, 'markeredgecolor', 'k');
drawPolyline(left_oriented, 'color', 'k', 'linewidth', 1);
in_edge = [x+500 2000 x+500 250];
out_edge = [x 1000 x 250];
drawEdge(in_edge, 'color', 'k', 'linestyle', ':');
drawEdge(out_edge, 'color', 'k', 'linestyle', ':');
text(x, 3750, 'Right');
text(x, 3500, 'oriented');


%%
Figures.makeFigure('TypesOfSpikes');
% matlab2tikz('export/TypesOfSpikes.tikz', 'parseStrings', false);

