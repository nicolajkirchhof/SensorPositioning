function in_environment = within_combined(environment, positions, eps)
%% WITHIN_COMBINED(environment, positions, eps)  calculates if one or multiple
%   positions are within the combined environment. Options
% eps : the distance at which a position is still within the environement. 


if isempty(environment.combined)
   environment = Environment.combine(environment);
end

[in_environment] = mb.inmultipolygon(environment.combined, int64(positions(1:2,:)));
%%% check distance to polygon edges for every other point
vertices = cell2mat(environment.combined);
dist_polygon_edges = mb.distancePoints(positions(1:2,~in_environment), vertices);
dist_polygon_edges_min = min(dist_polygon_edges, [], 2);
in_environment(~in_environment) = dist_polygon_edges_min < eps;

return;

%% TEST
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config = Configurations.Discretization.iterative;

environment = Environment.load(filename);
options = config.workspace;
options.positions.additional = 50;

workspace_positions = Discretization.Workspace.iterative( environment, options );

discretization = config;
options = config.sensorspace;
options.poses.additional = 0;
sensor = config.sensor;
options = Configurations.Sensorspace.iterative;

boundary_corners = mb.ring2corners(environment.boundary.ring);
boundary_corners_selection = boundary_corners(:, environment.boundary.isplaceable);

sensor_poses_boundary = Discretization.Sensorspace.place_sensors_on_corners(boundary_corners_selection, sensor.directional(2), options.resolution.angular, false);

%%% Poses on Mountable vertices
mountable_corners = cellfun(@mb.ring2corners, environment.mountable, 'uniformoutput', false);
fun_place_mountable = @(corners) Discretization.Sensorspace.place_sensors_on_corners(corners, sensor.directional(2), options.resolution.angular, true);
sensor_poses_mountables = cell2mat(cellfun(fun_place_mountable, mountable_corners, 'uniformoutput', false));

Discretization.Sensorspace.draw(sensor_poses_boundary);
Discretization.Sensorspace.draw(sensor_poses_mountables, 'g');
%%% Filter poses based on obstacles and visibility
sensor_poses_initial = [sensor_poses_boundary, sensor_poses_mountables];
sensor_poses = sensor_poses_initial;
in_environment = Environment.within_combined(environment, sensor_poses, 10);
sensor_poses_in = sensor_poses_initial(:, in_environment);
%%
Environment.draw(environment, false); 
%%
Discretization.Sensorspace.draw(sensor_poses_boundary);
Discretization.Sensorspace.draw(sensor_poses_mountables, 'g');
Discretization.Sensorspace.draw(sensor_poses_in, 'r');