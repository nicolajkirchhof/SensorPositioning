close all;
clear all;
%%
clear variables;
cla;
axis equal
hold on;
axis off

xlim([0 165]);
ylim([0 100]);

filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

polys = c_Poly(:,1);
edges = c_Line(:,1);
circles = c_Cir(:,1);


for idl = [1,2,3,4,5,7,10,12,13,14]
%     pause; disp(idl)
    edges{idl} = edges{idl}([1,2,4,5]);
    drawEdge(edges{idl}, 'color', 'k', 'linewidth', 1, 'linestyle', '--');
end

for idl = [6,8,9,11]
%     pause; disp(idl)
    edges{idl} = edges{idl}([1,2,4,5]);
%     drawEdge(edges{idl}, 'color', 'k', 'linewidth', 1, 'linestyle', ':');
end

r1 = createRay(edges{9}(1:2), edges{9}(3:4));
r2 = createRay(edges{11}(3:4), edges{11}(1:2));

xing_1 = intersectRayPolygon(createRay(edges{6}(1:2), edges{6}(3:4)), polys{1});
xing_2 = intersectRayPolygon(createRay(edges{8}(3:4), edges{8}(1:2)), polys{1});
drawEdge([edges{6}(1:2) xing_1], 'color', 'k', 'linewidth', 1, 'linestyle', ':');
drawEdge([edges{8}(3:4), xing_2], 'color', 'k', 'linewidth', 1, 'linestyle', ':');

xing_3 = intersectRayPolygon(r1, polys{1});
xing_4 = intersectRayPolygon(r2, polys{1});

drawEdge([edges{9}(1:2) xing_3], 'color', 'k', 'linewidth', 1, 'linestyle', ':');
drawEdge([edges{11}(3:4) xing_4], 'color', 'k', 'linewidth', 1, 'linestyle', ':');


for idp = 1:numel(polys)
    drawPolygon(polys{idp}, 'color', 'k', 'linewidth', 1);
end

 
% for idp = 2:numel(polys)
%     drawPoint(polys{idp}, 'marker', 'o', 'color', [0 0 0],'linewidth', 1, 'markersize', 8);
% end
% drawPoint(polys{idp}, 'marker', 'o', 'color', [0 0 0],'linewidth', 1, 'markersize', 8);
drawPoint(polys{4}(1,:), 'marker', 'o', 'color', [0 0 0], 'markersize', 5, 'markerfacecolor', [0 0 0]);
drawPoint(polys{3}(4,:), 'marker', 'o', 'color', [0 0 0], 'markersize', 5, 'markerfacecolor', [0 0 0]);

drawPoint(intersectEdges(edges{6}, edges{8}), 'marker', 'o', 'color', [0 0 0], 'markersize', 5, 'markerfacecolor', [0 0 0]);
drawPoint(intersectEdges(edges{9}, edges{11}), 'marker', 'o', 'color', [0 0 0], 'markersize', 5, 'markerfacecolor', [0 0 0]);

poly_edges = cell(1, numel(polys));
for idp = 1:numel(polys)
    poly_edges{idp} = [polys{idp}(1:end-1, :), polys{idp}(2:end, :)];
end
% plot
drawPoint(intersectRayPolygon(r1, polys{1}), 'marker', 'o', 'color', [0 0 0], 'markersize', 5, 'markerfacecolor', [0 0 0]);
drawPoint(intersectRayPolygon(r1, polys{2}), 'marker', 'o', 'color', [0 0 0], 'markersize', 5, 'markerfacecolor', [0 0 0]);

drawPoint(intersectRayPolygon(r2, polys{1}), 'marker', 'o', 'color', [0 0 0], 'markersize', 5, 'markerfacecolor', [0 0 0]);
drawPoint(intersectRayPolygon(r2, polys{2}), 'marker', 'o', 'color', [0 0 0], 'markersize', 5, 'markerfacecolor', [0 0 0]);


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


%%%
matlab2tikz('export/RadialPolygonDecompositionExplained.tikz', 'parseStrings', false,... 
    'tikzFileComment', 'width', '10cm', '% -*- root: TestingFigures.tex -*-',...
    'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});
% matlab2tikz('export/VfovIntersectionInvalidPolygon.tikz', 'parseStrings', false);