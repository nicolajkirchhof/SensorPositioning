%% Tests
filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

% vpoly = c_Poly(:,1);
vpoly = cellfun(@(x) x(1:end-1, :)*100,  c_Poly(:,1), 'UniformOutput', false);
vpoly(2:end) = cellfun(@flipud, vpoly(2:end), 'UniformOutput', false);
% vpoly(1) = cellfun(@reversePolygon, vpoly(1), 'UniformOutput', false);
bpoly = mb.visilibity2boost(vpoly);
% E_r = mb.radialPolygonSplitting(bpoly);
bpoly = cellfun(@(x) fliplr(circshift(x, -1, 1)), bpoly, 'uniformoutput', false);
% bpoly{1} = fliplr(bpoly{1});
%%
cla;
hold on;
% clf;
% axis equal;

for idn = 2:numel(bpoly)
    mb.fillPolygon(bpoly{idn}, 0.2*ones(1,3));
end
mb.drawPolygon(bpoly(2:end), 'color', 'k');
% axis on
p_part = polypartition(bpoly, 0);
part_edges = cellfun(@(x) [x', circshift(x', -1, 1)], p_part, 'uniformoutput', false);
fun_draw_edge = @(e) drawEdge(e, 'linewidth', 1, 'linestyle', '--', 'color', [0 0 0]);
% cellfun(@(x) fun_draw_edge(x), part_edges);
cellfun(@(x) fun_draw_edge(x(3,:)), part_edges);

fun_draw_edge(part_edges{9}([2], :));

% mb.drawPolygon(p_part,'linewidth', 1, 'color', [0 0 0], 'linestyle', '--');
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);
ylim([0 16400]);
xlim([-100 9100]);

axis off;
% Figures.makeFigure('TriangulationEarClipping', '5cm' );
filename = 'TriangulationEarClipping.tex';
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '4cm',...
    'width', '5cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);

Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);

%%
cla;
% axis equal;
hold on;
axis off;

for idn = 2:numel(bpoly)
    mb.fillPolygon(bpoly{idn}, 0.2*ones(1,3));
end
mb.drawPolygon(bpoly(2:end), 'color', 'k');
% mb.drawPolygon(polypartition(bpoly, 3), 'linewidth', 1, 'color', [0 0 0], 'linestyle', '--');
p_part = polypartition(bpoly, 3);
part_edges = cellfun(@(x) [x', circshift(x', -1, 1)], p_part, 'uniformoutput', false);
fun_draw_edge = @(e) drawEdge(e, 'linewidth', 1, 'linestyle', '--', 'color', [0 0 0]);

% cellfun(@(x) fun_draw_edge(x(3,:)), part_edges);
fun_draw_edge(part_edges{1}([1,3,4], :));
fun_draw_edge(part_edges{2}([3], :));
fun_draw_edge(part_edges{3}([1,3], :));
fun_draw_edge(part_edges{4}([3], :));
fun_draw_edge(part_edges{5}([4], :));
fun_draw_edge(part_edges{6}([2,4], :));
fun_draw_edge(part_edges{7}([3], :));
fun_draw_edge(part_edges{8}([3], :));
% fun_draw_edge(part_edges{9}([3], :));
fun_draw_edge(part_edges{10}([4], :));
fun_draw_edge(part_edges{11}([3], :));
fun_draw_edge(part_edges{12}([3], :));
fun_draw_edge(part_edges{13}([3], :));
% fun_draw_edge(part_edges{14}([4], :));

mb.drawPolygon(bpoly,'linewidth', 1, 'color', [0 0 0]);
ylim([0 16400]);
xlim([-100 9100]);

% Figures.makeFigure('TriangulationHertelMehlhorn', '5cm');
filename = 'TriangulationHertelMehlhorn.tex';
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '4cm',...
    'width', '5cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);

Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);

%% 
% clear variables;
cla;
% axis equal
hold on;
axis off
% axis on;
for idn = 2:numel(bpoly)
    mb.fillPolygon(bpoly{idn}, 0.2*ones(1,3));
end
mb.drawPolygon(bpoly(2:end), 'color', 'k');

filename = 'res/polygons/PolygonDecompositionWithoutSteinerPoints.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

polys = c_Poly(:,1);
edges = c_Line(:,1);
circles = c_Cir(:,1);

for idl = 1:numel(edges)
    edges{idl} = edges{idl}([1,2,4,5])*100;
    drawEdge(edges{idl}([2,1,4,3]), 'color', 'k', 'linewidth', 1, 'linestyle', '--');
end

for idp = 1:numel(polys)
    drawPolygon(polys{idp}(:, [2,1])*100, 'color', 'k', 'linewidth', 1);
end

ylim([0 16400]);
xlim([-100 9100]);

% Figures.makeFigure('ConvexDecompositionWithoutSteinerPoints', '5cm');
filename = 'ConvexDecompositionWithoutSteinerPoints.tex';
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '4cm',...
    'width', '5cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);

Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);
%%
% clear variables;
cla;
% axis equal
hold on;
axis off
for idn = 2:numel(bpoly)
    mb.fillPolygon(bpoly{idn}, 0.2*ones(1,3));
end
mb.drawPolygon(bpoly(2:end), 'color', 'k');

filename = 'res/polygons/PolygonDecompositionSteinerPoints.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

polys = c_Poly(:,1);
edges = c_Line(:,1);
circles = c_Cir(:,1);

for idl = 1:numel(edges)
    edges{idl} = edges{idl}([1,2,4,5])*100;
    drawEdge(edges{idl}([2,1,4,3]), 'color', 'k', 'linewidth', 1, 'linestyle', '--');
end

for idp = 1:numel(polys)
    drawPolygon(polys{idp}(:, [2,1])*100, 'color', 'k', 'linewidth', 1);
end

for idc = 1:numel(circles)
    drawPoint(circles{idc}([2,1])*100, 'color', [0 0 0], 'marker', 'o', 'markerfacecolor', [0 0 0], 'markersize', 6);
end

text(3800, 10000, '$p_s$', 'verticalalignment', 'middle', 'horizontalalignment', 'center', 'Rotation', -90);

ylim([0 16400]);
xlim([-100 9100]);
%%%
% Figures.makeFigure('ConvexDecompositionWithSteinerPoints', '5cm');
filename = 'ConvexDecompositionWithSteinerPoints.tex';
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '4cm',...
    'width', '5cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);

Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);
