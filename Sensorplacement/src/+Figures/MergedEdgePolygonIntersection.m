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

fun_draw_edge = @(e) drawEdge(e, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
drawPolygon(vpoly, 'color', [0 0 0], 'linewidth', 2);

e_r_edges = cell2mat(cellfun(@(x) x.edge, E_r(:)', 'uniformoutput', false)');


combs = comb2unique(1:size(e_r_edges, 1));
e_r_intersections = intersectEdges(e_r_edges(combs(:,1), :), e_r_edges(combs(:,2), :));

xing_points = e_r_intersections(~isnan(e_r_intersections(:,1)), :);

drawPoint(xing_points, 'color', [0 0 0], 'markerfacecolor', [0 0 0]);
% drawPoint([100 100], 'color', [0 0 0], 'markerfacecolor', [0 0 0]);
% drawPoint([100 300], 'color', [0 0 0], 'markerfacecolor', [0 0 0]);

%%%
% axis on;
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
matlab2tikz('export/MergedEdgePolygonIntersection.tikz', 'parseStrings', false,...
    'tikzFileComment', 'width', '10cm', '% -*- root: TestingFigures.tex -*-',...
    'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});
% matlab2tikz('export/VfovIntersectionInvalidPolygon.tikz', 'parseStrings', false);
%%
[P_c, E_r] = mb.polygonConvexDecomposition(mb.visilibity2boost({vpoly}));
% cla;
drawPolygon(P_c)
set(gca, 'CameraUpVector', [1 0 0]);
% set(gca, 'YAxisLocation', 'bottom');
%%

for idl = [1,2,3,4,5,7,10,12,13,14]
    %     pause; disp(idl)
    edges{idl} = edges{idl}([1,2,4,5]);
    drawEdge(edges{idl}, 'color', 'k', 'linewidth', 2, 'linestyle', '--');
end

for idl = [6,8,9,11]
    %     pause; disp(idl)
    edges{idl} = edges{idl}([1,2,4,5]);
    %     drawEdge(edges{idl}, 'color', 'k', 'linewidth', 2, 'linestyle', ':');
end

r1 = createRay(edges{9}(1:2), edges{9}(3:4));
r2 = createRay(edges{11}(3:4), edges{11}(1:2));
drawRay(createRay(edges{6}(1:2), edges{6}(3:4)), 'color', 'k', 'linewidth', 2, 'linestyle', ':');
drawRay(createRay(edges{8}(3:4), edges{8}(1:2)), 'color', 'k', 'linewidth', 2, 'linestyle', ':');
drawRay(r1, 'color', 'k', 'linewidth', 2, 'linestyle', ':');
drawRay(r2, 'color', 'k', 'linewidth', 2, 'linestyle', ':');


for idp = 1:numel(polys)
    drawPolygon(polys{idp}, 'color', 'k', 'linewidth', 2);
end


% for idp = 2:numel(polys)
%     drawPoint(polys{idp}, 'marker', 'o', 'color', [0 0 0],'linewidth', 2, 'markersize', 8);
% end
% drawPoint(polys{idp}, 'marker', 'o', 'color', [0 0 0],'linewidth', 2, 'markersize', 8);
drawPoint(polys{4}(1,:), 'marker', 'o', 'color', [0 0 0], 'markersize', 6, 'markerfacecolor', [0 0 0]);
drawPoint(polys{3}(4,:), 'marker', 'o', 'color', [0 0 0], 'markersize', 6, 'markerfacecolor', [0 0 0]);

drawPoint(intersectEdges(edges{6}, edges{8}), 'marker', 'o', 'color', [0 0 0], 'markersize', 6, 'markerfacecolor', [0 0 0]);
drawPoint(intersectEdges(edges{9}, edges{11}), 'marker', 'o', 'color', [0 0 0], 'markersize', 6, 'markerfacecolor', [0 0 0]);

poly_edges = cell(1, numel(polys));
for idp = 1:numel(polys)
    poly_edges{idp} = [polys{idp}(1:end-1, :), polys{idp}(2:end, :)];
end
% plot
drawPoint(intersectRayPolygon(r1, polys{1}), 'marker', 'o', 'color', [0 0 0], 'markersize', 6, 'markerfacecolor', [0 0 0]);
drawPoint(intersectRayPolygon(r1, polys{2}), 'marker', 'o', 'color', [0 0 0], 'markersize', 6, 'markerfacecolor', [0 0 0]);

drawPoint(intersectRayPolygon(r2, polys{1}), 'marker', 'o', 'color', [0 0 0], 'markersize', 6, 'markerfacecolor', [0 0 0]);
drawPoint(intersectRayPolygon(r2, polys{2}), 'marker', 'o', 'color', [0 0 0], 'markersize', 6, 'markerfacecolor', [0 0 0]);

text(97, 40, '$p_s$', 'horizontalalignment', 'center');
% text(10, 40, '$p_s$', 'horizontalalignment', 'center');

text(80, 59, '$v_{s}$', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(80, 32, '$v_{s''}$', 'horizontalalignment', 'center', 'verticalalignment', 'top');

text(117, 70, '$p_{x''}$', 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(117, 22, '$p_{x}$', 'horizontalalignment', 'center', 'verticalalignment', 'top');

text(84, 45, '$e_{n}$', 'rotation', 90, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

text(94, 80, '$e_{r1}$', 'rotation', 45, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(113, 80, '$e_{r2}$', 'rotation', -45, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(115, 7, '$e_{r3}$', 'rotation', 45, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(94, 6, '$e_{r4}$', 'rotation', -45, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(153, 8, '$e_{r5}$', 'rotation', -34, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(156, 80, '$e_{r6}$', 'rotation', 30, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

text(89, 68, '$e_{a}$', 'rotation', 0, 'horizontalalignment', 'center', 'verticalalignment', 'middle');
text(89, 23, '$e_{b}$', 'rotation',  0, 'horizontalalignment', 'center', 'verticalalignment', 'middle');
text(122, 45, '$e_{c}$', 'rotation', 0, 'horizontalalignment', 'right', 'verticalalignment', 'middle');

text(50, -1, '$e_{d}$', 'rotation', 0, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(103, -1, '$e_{d''}$', 'rotation', 0, 'horizontalalignment', 'center', 'verticalalignment', 'top');
text(133, -1, '$e_{d''''}$', 'rotation', 0, 'horizontalalignment', 'center', 'verticalalignment', 'top');

text(50, 92, '$e_{e}$', 'rotation', 0, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(103, 92, '$e_{e''}$', 'rotation', 0, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(133, 92, '$e_{e''''}$', 'rotation', 0, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');

text(134, 71, '$e_{f}$', 'rotation', 0, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
text(134, 15, '$e_{g}$', 'rotation', 0, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');
% text(133, 91, '$e_{h}$', 'rotation', 0, 'horizontalalignment', 'center', 'verticalalignment', 'bottom');


% axis on;


