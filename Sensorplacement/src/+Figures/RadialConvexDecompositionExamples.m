close all;
clear all;
%%
clear variables;
cla;
axis equal
hold on;
axis off
% set(gca, 'CameraUpVector', [1 0 0]);

% filename = 'res/floorplans/SmallFlat.dxf';
% [c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

% polys = c_Poly(:,1);
% edges = c_Line(:,1);
% circles = c_Cir(:,1);
% env = Environment.load(filename);
% env.obstacles = {};
% env_comb = Environment.combine(env);
% bpoly = env_comb.combined;
% [(1:39)', vpoly{1}']
% vpoly{1}(2,23) = 5815;
% vpoly{1}(2,24) = 5915;
% bpoly = cellfun(@(x) circshift(x, -1, 1), bpoly, 'uniformoutput', false);

% mb.drawPolygon(bpoly);

% [P_c, E_r] = mb.polygonConvexDecomposition(bpoly);
load tmp\small_flat\environment\environment.mat
input = Experiments.Diss.small_flat(500, 500);
P_c = environment.P_c;
E_r = environment.E_r;
bpoly = environment.combined;

mb.drawPoint(input.discretization.wpn, 'marker', '.', 'color', [0.6, 0.6, 0.6], 'markersize', 4);
mb.drawPolygon(environment.occupied, 'color', [0.6, 0.6, 0.6]);
% mb.drawPolygon(environment.mountable, 'color', [0.6, 0.6, 0.6]);
fun_draw_edge = @(e) drawEdge(e, 'linewidth', 1, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);
% axis on
ylim([50 8600]);
xlim([400 6100]);
%%
filename = 'DecomposedSmallFlat';
Figures.makeFigure(filename, '5cm');

%%
clear variables;
cla;
axis equal
hold on;
axis off
% set(gca, 'CameraUpVector', [0 1 0]);
load tmp\conference_room\environment\environment.mat
input = Experiments.Diss.conference_room(500, 500);
bpoly = environment.combined;

mb.drawPoint(input.discretization.wpn, 'marker', '.', 'color', [0.6, 0.6, 0.6], 'markersize', 4);
mb.drawPolygon(environment.occupied, 'color', [0.6, 0.6, 0.6]);
% mb.drawPolygon(environment.mountable, 'color', [0.6, 0.6, 0.6]);
% fun_draw_edge = @(e) drawEdge(e, 'linewidth', 1, 'linestyle', '--', 'color', [0 0 0]);
% cellfun(@(x) fun_draw_edge(x.edge), E_r);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);

%%
axis on
ylim([300 7500]);
xlim([300 5250]);
%%
Figures.makeFigure('DecomposedP1-Seminarraum', '5cm');

%%
clear variables;
cla;
axis equal
hold on;
axis off

load tmp\large_flat\environment\environment.mat
input = Experiments.Diss.large_flat(500, 500);
P_c = environment.P_c;
E_r = environment.E_r;
bpoly = environment.combined;

mb.drawPoint(input.discretization.wpn, 'marker', '.', 'color', [0.6, 0.6, 0.6], 'markersize', 4);
mb.drawPolygon(environment.occupied, 'color', [0.6, 0.6, 0.6]);
% mb.drawPolygon(environment.mountable, 'color', [0.6, 0.6, 0.6]);


mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);
fun_draw_edge = @(e) drawEdge(e, 'linewidth', 1, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
% drawPolygon(P_c, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);


xlim([750 13100]);
ylim([300 9200]);
%%
Figures.makeFigure('DecomposedLargeFlat', '8cm');
% fprintf(1, 'LargeFlat is decomposed into %d convex polygons.\n', numel(P_c));

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
env = Environment.load(filename);
env.obstacles = {};
env_comb = Environment.combine(env);
% mb.drawPolygon(env_comb.combined);
%%%
vpoly_full = mb.boost2visilibity(env_comb.combined);
vpoly = cellfun(@(x) simplifyPolyline(x, 70), vpoly_full, 'uniformoutput', false);
% drawPolygon(vpoly);
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

bpoly = cellfun(@(x) circshift(x, -1, 1), bpoly, 'uniformoutput', false);

[P_c, E_r] = mb.polygonConvexDecomposition(bpoly);

fun_draw_edge = @(e) drawEdge(e, 'linewidth', 1, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
% drawPolygon(P_c, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);
%%%
% axis on
ylim([300 49800]);
xlim([300 15500]);
Figures.makeFigure('DecomposedP1-01-EtPart');
fprintf(1, 'P1-01-EtPart is decomposed into %d convex polygons.\n', numel(P_c));

%%
