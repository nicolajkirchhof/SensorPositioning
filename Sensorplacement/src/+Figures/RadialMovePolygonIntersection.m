close all;
clear all;
%%
clear variables;
cla;
axis equal
hold on;
axis off

vpoly  = [100 0;
%     100 100;
%     150 0;
    175 0;
    175 500;
    225 500;
    225 0;
    250 0;
    300 100;
    400 0;
    400 1000;
    225 1000;
    225 925;
    175 925;
    175 1000;
    100 1000];
vpoly = circshift(vpoly, -1, 2);

E_r = g2d.radialPolygonSplitting({vpoly});

fun_draw_edge = @(e) drawEdge(e, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r(2:end-1));

drawPolygon(vpoly, 'color', [0 0 0], 'linewidth', 2);

e_r_edges = cell2mat(cellfun(@(x) x.edge, E_r(:)', 'uniformoutput', false)');

merged_edge = [500 175 925 175];
drawEdge(merged_edge, 'linewidth', 2, 'linestyle', ':', 'color', [0 0 0]);

combs = comb2unique(1:size(e_r_edges, 1));
e_r_intersections = intersectEdges(e_r_edges(combs(:,1), :), e_r_edges(combs(:,2), :));

xing_points = e_r_intersections(~isnan(e_r_intersections(:,1)), :);

e_n_xing = intersectEdges(E_r{3}.edge, merged_edge);
drawPoint(xing_points(2,:), 'color', [0 0 0], 'markerfacecolor', [0 0 0]);
% drawPoint([500 175], 'color', [0 0 0], 'markerfacecolor', [0 0 0]);
% drawPoint([100 300], 'color', [0 0 0], 'markerfacecolor', [0 0 0]);
% drawPoint([100 300], 'color', [0 0 0], 'markerfacecolor', [0 0 0]);
drawPoint(e_n_xing, 'color', [0 0 0], 'markerfacecolor', [0 0 0]);

interx_edge = [100 300 500 175];
drawEdge(interx_edge, 'linewidth', 2, 'linestyle', '-.', 'color', [0 0 0]);
xing_poly = intersectEdges(interx_edge, [0 225 500 225]);
drawPoint(xing_poly, 'color', [0 0 0], 'markerfacecolor', [0 0 0]);

% %%%
% axis on;
% text(100, 110, '$v_{1}$', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(100, 310 , '$v_{1}$', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(320, 205 , '$v_{1,p}$', 'horizontalalignment', 'center', 'verticalalignment', 'middle');

% text(490, 250, '$c_{2,y}$', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
% text(490, 150, '$c_{1,x}$', 'horizontalalignment', 'center', 'verticalalignment', 'top');
% text(700, 210, '$c_{1,2}$', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
% text(550, 250, '$v_{y}$', 'horizontalalignment', 'left', 'verticalalignment', 'middle');
% text(550, 150, '$v_{x}$', 'horizontalalignment', 'left', 'verticalalignment', 'middle');

%%%
% drawPolygon(vpoly);

ylim([90 410]);
xlim([-10 1010]);

%%%
matlab2tikz('export/RadialMovePolygonIntersection.tikz', 'parseStrings', false,...
    'tikzFileComment', 'width', '10cm', '% -*- root: TestingFigures.tex -*-',...
    'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});
% matlab2tikz('export/VfovIntersectionInvalidPolygon.tikz', 'parseStrings', false);
