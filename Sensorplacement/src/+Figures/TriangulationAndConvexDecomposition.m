%% Tests
filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

% vpoly = c_Poly(:,1);
vpoly = cellfun(@(x) x(1:end-1, :)*100,  c_Poly(:,1), 'UniformOutput', false);
vpoly(2:end) = cellfun(@flipud, vpoly(2:end), 'UniformOutput', false);
% vpoly(1) = cellfun(@reversePolygon, vpoly(1), 'UniformOutput', false);
bpoly = mb.visilibity2boost(vpoly);
% E_r = mb.radialPolygonSplitting(bpoly);

%%
cla;
axis equal;
axis off;
xlim([0 16250]);
mb.drawPolygon(polypartition(bpoly, 0), 'color', [0 0 0], 'linestyle', ':');
mb.drawPolygon(bpoly, 'color', [0 0 0]);
matlab2tikz('export/TriangulationEarClipping.tikz', 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '10cm',...
...    'height', '5cm', 
    'extraAxisOptions',{'y post scale=1'});
%%
cla;
axis equal;
mb.drawPolygon(polypartition(bpoly, 3), 'color', [0 0 0], 'linestyle', ':');
mb.drawPolygon(bpoly, 'color', [0 0 0]);
matlab2tikz('export/TriangulationHertelMehlhorn.tikz', 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '10cm',...
...    'height', '5cm', 
    'extraAxisOptions',{'y post scale=1'});