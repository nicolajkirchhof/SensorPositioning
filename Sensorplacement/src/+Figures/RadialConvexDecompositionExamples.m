close all;
clear all;
%%
clear variables;
cla;
axis equal
hold on;
axis off

xlim([0 6000]);
ylim([500 8800]);

filename = 'res/floorplans/SmallFlat.dxf';
% [c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

% polys = c_Poly(:,1);
% edges = c_Line(:,1);
% circles = c_Cir(:,1);
env = environment.load(filename);
env.obstacles = {};
env_comb = environment.combine(env);
vpoly = env_comb.combined;
% [(1:39)', vpoly{1}']
% vpoly{1}(2,23) = 5815;
% vpoly{1}(2,24) = 5915;

mb.drawPolygon(vpoly);

[P_c, E_r] = mb.polygonConvexDecomposition(vpoly);

fun_draw_edge = @(e) drawEdge(e, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
% drawPolygon(P_c, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
mb.drawPolygon(env_comb.combined, 'color', [0 0 0], 'linewidth', 2);
% axis on
xlim([50 5900]);
ylim([500 8800]);

matlab2tikz('export/DecomposedSmallFlat.tikz', 'parseStrings', false,... 
    'tikzFileComment', 'width', '10cm', '% -*- root: TestingFigures.tex -*-',...
    'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});
fprintf(1, 'SmallFlat is decomposed into %d convex polygons.\n', numel(P_c));

%%%
clear variables;
cla;
axis equal
hold on;
axis off

filename = 'res/floorplans/P1-Seminarraum.dxf';
% [c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

% polys = c_Poly(:,1);
% edges = c_Line(:,1);
% circles = c_Cir(:,1);
env = environment.load(filename);
env.obstacles = {};
env_comb = environment.combine(env);
mb.drawPolygon(env_comb.combined);

[P_c, E_r] = mb.polygonConvexDecomposition(env_comb.combined);

fun_draw_edge = @(e) drawEdge(e, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
% drawPolygon(P_c, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
mb.drawPolygon(env_comb.combined, 'color', [0 0 0], 'linewidth', 2);

% axis on
xlim([250 3900]);
ylim([1150 8400]);

matlab2tikz('export/DecomposedP1-Seminarraum.tikz', 'parseStrings', false,... 
    'tikzFileComment', 'width', '10cm', '% -*- root: TestingFigures.tex -*-',...
    'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});
fprintf(1, 'P1-Seminarraum is decomposed into %d convex polygons.\n', numel(P_c));

%%
clear variables;
cla;
axis equal
hold on;
axis off
% axis on

filename = 'res/floorplans/LargeFlat.dxf';
% [c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

% polys = c_Poly(:,1);
% edges = c_Line(:,1);
% circles = c_Cir(:,1);
env = environment.load(filename);
env.obstacles = {};
env_comb = environment.combine(env);
% mb.drawPolygon(env_comb.combined);
%%%
vpoly_full = mb.boost2visilibity(env_comb.combined);
vpoly = cellfun(@(x) simplifyPolyline(x, 75), vpoly_full, 'uniformoutput', false);
% vpoly{2}(:,1) = vpoly{2}(:,1)+3;
% drawPolygon(vpoly);
%%%
bpoly = mb.visilibity2boost(vpoly);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 2);

[P_c, E_r] = mb.polygonConvexDecomposition(bpoly);

fun_draw_edge = @(e) drawEdge(e, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
% drawPolygon(P_c, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);


xlim([750 13100]);
ylim([300 9200]);
% axis on
matlab2tikz('export/DecomposedLargeFlat.tikz', 'parseStrings', false,... 
    'tikzFileComment', 'width', '10cm', '% -*- root: TestingFigures.tex -*-',...
    'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});
fprintf(1, 'LargeFlat is decomposed into %d convex polygons.\n', numel(P_c));

%%
clear variables;
cla;
axis equal
hold on;
axis off
% xlim 'auto'

filename = 'res/floorplans/P1-01-EtPart.dxf';
% [c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

% polys = c_Poly(:,1);
% edges = c_Line(:,1);
% circles = c_Cir(:,1);
env = environment.load(filename);
env.obstacles = {};
env_comb = environment.combine(env);
% mb.drawPolygon(env_comb.combined);
%%%
vpoly_full = mb.boost2visilibity(env_comb.combined);
vpoly = cellfun(@(x) simplifyPolyline(x, 70), vpoly_full, 'uniformoutput', false);
drawPolygon(vpoly);
% vpoly{1}(69:72, 1) = vpoly{1}(69:72, 1) + 2;
vpoly{1}(21:23, 1) = vpoly{1}(21:23, 1) - 2;
vpoly{1}(59, 1) = 15605;


%           70       23805        7044
%           71       23955        7044
%           21       23957        8011
%           22       23807        8011
%           59       15620        4112
%           60       16105        4112
%           61       16105        6252
%           62       15605        6252
%%%
bpoly = mb.visilibity2boost(vpoly);
[P_c, E_r] = mb.polygonConvexDecomposition(bpoly);

fun_draw_edge = @(e) drawEdge(e, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
% drawPolygon(P_c, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 2);
%%%
% axis on
xlim([300 49800]);
ylim([300 15500]);
matlab2tikz('export/DecomposedP1-01-EtPart.tikz', 'parseStrings', false,... 
    'tikzFileComment', 'width', '10cm', '% -*- root: TestingFigures.tex -*-',...
    'extraAxisOptions',{'y post scale=1', 'unit vector ratio=1 1 1'});
fprintf(1, 'P1-01-EtPart is decomposed into %d convex polygons.\n', numel(P_c));

%%
