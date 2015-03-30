close all;
clear all;
%%
clear variables;
cla;
axis equal
hold on;
axis off

load tmp\small_flat\environment\environment.mat
input = Experiments.Diss.small_flat(500, 500);
inputbase = Experiments.Diss.small_flat(0, 0);
wpnbase = inputbase.discretization.wpn;
input200 = Experiments.Diss.small_flat(200, 200);
wpn200 = input200.discretization.wpn;
P_c = environment.P_c;
E_r = environment.E_r;
bpoly = environment.combined;

% mb.drawPoint(input.discretization.wpn, 'marker', '.', 'color', [0.6, 0.6, 0.6], 'markersize', 4);

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

% axis on
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

load tmp\office_floor\environment\environment.mat
input = Experiments.Diss.office_floor(500, 500);
P_c = environment.P_c;
E_r = environment.E_r;
bpoly = environment.combined;

mb.drawPoint(input.discretization.wpn, 'marker', '.', 'color', [0.6, 0.6, 0.6], 'markersize', 4);
mb.drawPolygon(environment.occupied, 'color', [0.6, 0.6, 0.6]);
% mb.drawPolygon(environment.mountable, 'color', [0.6, 0.6, 0.6]);

fun_draw_edge = @(e) drawEdge(e, 'linewidth', 1, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
% drawPolygon(P_c, 'linewidth', 2, 'linestyle', '--', 'color', [0 0 0]);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);
%%
% axis on
ylim([300 14500]);
xlim([300 29000]);
%%
Figures.makeFigure('DecomposedOfficeFloor', '10cm');
% fprintf(1, 'P1-01-EtPart is decomposed into %d convex polygons.\n', numel(P_c));

