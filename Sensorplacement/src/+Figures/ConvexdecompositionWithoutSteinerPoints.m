close all;
clear all;
%%
clear variables;
cla;
axis equal
hold on;
axis off

% xlim([-300 5300]);
% ylim([-300 3300]);

filename = 'res/polygons/PolygonDecompositionWithoutSteinerPoints.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

polys = c_Poly(:,1);
edges = c_Line(:,1);
circles = c_Cir(:,1);

for idl = 1:numel(edges)
    edges{idl} = edges{idl}([1,2,4,5]);
    drawEdge(edges{idl}, 'color', 'k', 'linewidth', 2, 'linestyle', '--');
end

for idp = 1:numel(polys)
    drawPolygon(polys{idp}, 'color', 'k', 'linewidth', 2);
end

% for idc = 1:numel(circles)
%     drawCircle(circles{idc}, 'color', 'k');
%     fillPolygon(circleToPolygon(circles{idc}, 128), 'k');
% end

% text(98, 40, 'SP');



%%
matlab2tikz('export/ConvexDecompositionWithoutSteinerPoints.tikz', 'parseStrings', false,... 
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-',...
    'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});
% matlab2tikz('export/VfovIntersectionInvalidPolygon.tikz', 'parseStrings', false);