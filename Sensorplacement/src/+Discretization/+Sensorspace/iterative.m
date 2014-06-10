function [sensor_poses, vfovs, vm] = iterative(environment, workspace_positions, options)
%% ITERATIVE(environment, sensor, workspace_positions, options) samples the sensorspace
%    by edge splitting. Options is a discretization with the following suboptions set for 
%   the sensorposes.
% options.resolution.angular : angular resolution per vertex
% options.poses.additional : number of additional poses to the vertex poses
%
% Right now 2.6.14 the orientation of the environment is ccw for the outer boundary 
% and cw for the inner mountable rings, therfore the corners have to be processed
% in reverse order.
% bpolyclip
%% set options
sensor = options.sensor;
sensorspace = options.sensorspace;

%% Poses on Boundary vertices
boundary_corners = mb.ring2corners(environment.boundary.ring);
boundary_corners_selection = boundary_corners(:, environment.boundary.isplaceable);

sensor_poses_boundary = Discretization.Sensorspace.place_sensors_on_corners(boundary_corners_selection, sensor.directional(2), sensorspace.resolution.angular, false);

%%% Poses on Mountable vertices
mountable_corners = cellfun(@mb.ring2corners, environment.mountable, 'uniformoutput', false);
fun_place_mountable = @(corners) Discretization.Sensorspace.place_sensors_on_corners(corners, sensor.directional(2), sensorspace.resolution.angular, true);
sensor_poses_mountables = cell2mat(cellfun(fun_place_mountable, mountable_corners, 'uniformoutput', false));

% Discretization.Sensorspace.draw(sensor_poses_boundary);
% Discretization.Sensorspace.draw(sensor_poses_mountables, 'g');
%%% Filter poses based on obstacles and visibility
sensor_poses_initial = [sensor_poses_boundary, sensor_poses_mountables];
% sensor_poses = sensor_poses_initial;

%%% check if points are in environment
environment = Environment.combine(environment);
in_environment = Environment.within_combined(environment, sensor_poses_initial, 10);
sensor_poses_in = sensor_poses_initial(:, in_environment);
[sensor_poses, vfovs, vm] = Discretization.Sensorspace.vfov(sensor_poses_in, environment, workspace_positions, options);

% Discretization.Sensorspace.draw(sensor_poses_initial_in, 'm');
%% Add additional positions iterative
mountable_corners_flat = cell2mat(mountable_corners);
if ~isempty(mountable_corners_flat)
edges = [boundary_corners(1:4, :), mountable_corners_flat([3,4,1,2],:)];
else
    edges = [boundary_corners(1:4, :)];
end

sensor_poses_add = {};
vfovs_add = {};
vm_add = {};
cnt = 0;
%%
while cnt < sensorspace.poses.additional
    %%
edgelengths = sum((edges(1:2,:)-edges(3:4,:)).^2, 1);
[~, idmax] = max(edgelengths);
edge = edges(:, idmax);
split_vertex = edge(1:2)+0.5*(edge(3:4)-edge(1:2));
% mb.drawPoint(split_vertex);
corner = [edge(1:2);split_vertex;edge(3:4)];
sensor_poses_corner = Discretization.Sensorspace.place_sensors_on_corners(corner, sensor.directional(2), sensorspace.resolution.angular, false);
in_environment = Environment.within_combined(environment, sensor_poses_corner, 10);
sensor_poses_corner_in = sensor_poses_corner(:, in_environment);


[sensor_poses_tmp, vfovs_tmp, vm_tmp] = Discretization.Sensorspace.vfov(sensor_poses_corner_in, environment, workspace_positions, options);
%%% select sensors
sensors_to_place = sensorspace.poses.additional - cnt;
if size(sensor_poses_tmp, 2) > sensors_to_place
    sensor_poses_tmp = sensor_poses_tmp(:, 1:sensors_to_place);
    vfovs_tmp = vfovs_tmp(1:sensors_to_place);
    vm_tmp = vm_tmp(1:sensors_to_place, :);
end
%%% update variables
cnt = cnt + size(sensor_poses_tmp, 2);
edges = [edges(:, 1:idmax-1), edges(:, idmax+1:end), corner(1:4), corner(3:6)];

if ~isempty(sensor_poses_tmp)
    sensor_poses_add{end+1} = sensor_poses_tmp;
    vfovs_add = [vfovs_add, vfovs_tmp];
    vm_add{end+1} = vm_tmp;
end
end

sensor_poses = [sensor_poses, cell2mat(sensor_poses_add)];
vfovs = [vfovs, vfovs_add];
vm = [vm; cell2mat(vm_add')];

return;
%% TEST
% close all; 
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
options = Configurations.Discretization.iterative;

environment = Environment.load(filename);
options.workspace.positions.additional = 50;

workspace_positions = Discretization.Workspace.iterative( environment, options );

% options = config;
%%
% for npts = randi(800, 1, 20)
npts = 100;
options.sensorspace.poses.additional = npts;
%%%
cla
Environment.draw(environment, false); 
%%%
[sensor_poses, vfovs, vm] = Discretization.Sensorspace.iterative(environment, workspace_positions, options);

Discretization.Sensorspace.draw(sensor_poses);
cellfun(@(p) mb.drawPoint(p{1}{1}(:,2), 'color', 'g'), vfovs)
% Discretization.Sensorspace.draw(sensor_poses_mountables, 'g');
% Discretization.Sensorspace.draw(sensor_poses_initial_in, 'r');
disp(npts);
% pause;
% end
%%
