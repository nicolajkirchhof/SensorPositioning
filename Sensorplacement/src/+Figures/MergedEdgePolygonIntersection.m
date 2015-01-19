close all;
clear all;
%%
clear variables;
cla;
axis equal
hold on;
axis off

vpoly  = [0 0;
    100 100;
    150 0;
    175 0;
    175 500;
    225 500;
    225 0;
    250 0;
    300 100;
    400 0;
    400 750;
    0 750];
vpoly = circshift(vpoly, -1, 2);

E_r = g2d.radialPolygonSplitting({vpoly});

fun_draw_edge = @(e) drawEdge(e, 'linewidth', 1, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
drawPolygon(vpoly, 'color', [0 0 0], 'linewidth', 1);

e_r_edges = cell2mat(cellfun(@(x) x.edge, E_r(:)', 'uniformoutput', false)');


combs = comb2unique(1:size(e_r_edges, 1));
e_r_intersections = intersectEdges(e_r_edges(combs(:,1), :), e_r_edges(combs(:,2), :));

xing_points = e_r_intersections(~isnan(e_r_intersections(:,1)), :);

drawPoint(xing_points, 'color', [0 0 0], 'markerfacecolor', [0 0 0], 'markersize', 5);
% drawPoint([100 100], 'color', [0 0 0], 'markerfacecolor', [0 0 0]);
% drawPoint([100 300], 'color', [0 0 0], 'markerfacecolor', [0 0 0]);

text(100, 110, '$v_{1}$', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(100, 310 , '$v_{2}$', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(490, 250, '$c_{2,y}$', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(490, 150, '$c_{1,x}$', 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(700, 210, '$c_{1,2}$', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
% text(550, 250, '$v_{y}$', 'horizontalalignment', 'left', 'verticalalignment', 'middle');
% text(550, 150, '$v_{x}$', 'horizontalalignment', 'left', 'verticalalignment', 'middle');

%%%
% drawPolygon(vpoly);

ylim([-10 410]);
xlim([-10 760]);

%%%
Figures.makeFigure('MergedEdgePolygonIntersection');
% matlab2tikz('export/MergedEdgePolygonIntersection.tikz', 'parseStrings', false,...
%     'tikzFileComment', 'width', '10cm', '% -*- root: TestingFigures.tex -*-',...
%     'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});
% matlab2tikz('export/VfovIntersectionInvalidPolygon.tikz', 'parseStrings', false);
%%
[P_c, E_r] = mb.polygonConvexDecomposition(mb.visilibity2boost({vpoly}));
% cla;
drawPolygon(P_c)
set(gca, 'CameraUpVector', [1 0 0]);
% set(gca, 'YAxisLocation', 'bottom');