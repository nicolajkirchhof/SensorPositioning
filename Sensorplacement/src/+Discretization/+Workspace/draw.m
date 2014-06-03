function draw(positions)
%% DRAW(workspace) draws the workspace positions as green points in the current
%   axes

holdison = false;
if ishold
    holdison = true;
end

hold on; 
h = drawPoint(positions', '.g');
legend(h(1), 'Workspace Point');
legend off;
legend show;

if ~holdison
    hold off;
end

return;

%% TEST points
% close all; 
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config = Configurations.Discretization.iterative;
environment = Environment.load(filename);

options = config.workspace;
placeable_ring = mb.expandPolygon(environment.boundary.ring, -options.wall_distance);
p1 = min(placeable_ring{1}, [], 2);
p2 = max(placeable_ring{1}, [], 2);
[gx, gy] = meshgrid(p1(1):10:p2(1), p1(2):10:p2(2));
positions = [gx(:), gy(:)]';

Discretization.Workspace.draw(positions);

% in = Environment.within(environment, positions);