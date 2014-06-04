function in = within(environment, positions, check_mountables)
%% INENVIRONMENT(environment, positions) tests if the positions are in the environment
%   and not inside a mountable occupied or obstacle.
%   check_mountables : boolean if mountables and outer boundary are to be checked 
%       which is false for sensor_poses

if nargin < 3
    check_mountables = true;
end

if check_mountables
in = binpolygon(positions, environment.boundary.ring);
else 
    in = true(1, size(positions, 2));
end

if ~isempty(environment.occupied)
%     occupied = mb.expandPolygon(environment.occupied, pc.workspace.wall_distance);
%     occupied_merged = bpolyclip_batch(pc.workspace.environment.occupied, 3, 1:numel(occupied), pc.common.bpolyclip_batch_options);
%     pc.workspace.environment.occupied = occupied_merged{1};
%     [in_occupied, ~] = binpolygon(positions, pc.workspace.environment.occupied);
    [in_occupied] = mb.inmultipolygon(environment.occupied, positions);
    in  = in & ~in_occupied;
%     positions = positions(:, ~in_occupied);
end

if ~isempty(environment.obstacles)
%     pc.workspace.environment.obstacles = mb.expandPolygon(environment.obstacles, pc.workspace.wall_distance);
    [in_obstacle] = mb.inmultipolygon(environment.obstacles, positions);
    in = in & ~in_obstacle;
%     positions = positions(:, ~in_obstacle);
end
%%
if check_mountables && ~isempty(environment.mountable)
%     environment.mountable = mb.expandPolygon(environment.mountable, wall_distance);
    [in_mountable] = mb.inmultipolygon(environment.mountable, positions);
    in = in & ~in_mountable;
%     positions = positions(:,~any(in_mountable,1));
end

return;

%% TEST
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

in = Environment.within(environment, positions);
Environment.draw(environment);
hold on;
mb.drawPoint(positions(:, in), '.g');
mb.drawPoint(positions(:, ~in), '.r');
%% Test check mountables
cla
in_cm = Environment.within(environment, positions, false);
Environment.draw(environment);
hold on;
mb.drawPoint(positions(:, in_cm), '.g');
mb.drawPoint(positions(:, ~in_cm), '.r');

% base_workspace_positions = 

% options = Configurations.Sensorspace.iterative;


% pc.problem.W = double(positions);
% pc.workspace.number_of_positions = size(positions,2);