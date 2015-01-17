function [sensor_poses, vfovs, vm] = iterative(environment, workspace_positions, options, debug)
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
if nargin < 4
    debug = [];
end
%% set options
sensor = options.sensor;
sensorspace = options.sensorspace;

%% Redo environment to add points that are on obstacles
%%% Test obstacle point integration
boundary_vpoly = mb.boost2visilibity(environment.boundary.ring);
boundary_edges = [boundary_vpoly, circshift(boundary_vpoly, -1, 1)];
obstacle_vpolys = cellfun(@(x)mb.boost2visilibity(x{1}), environment.obstacles, 'uniformoutput', false);
obstacle_edges = cellfun(@(x) [x, circshift(x, -1, 1)], obstacle_vpolys,  'uniformoutput', false);
%%%
for id_poly = 1:numel(obstacle_edges)
    %%
    edges = obstacle_edges{id_poly};
    for id_edge =  1:size(edges, 1)
        %%
        xings = intersectEdges(edges(id_edge,:), boundary_edges);
        flt_xing = ~isnan(xings(:,1)) & ~isinf(xings(:,1));
        if any(flt_xing)
            id_xings = find(flt_xing);
            for id_xing = id_xings
                boundary_edges = [boundary_edges(1:id_xing-1, :);
                    [ boundary_edges(id_xing, 1:2), xings(id_xing, :) ];
                    [ xings(id_xing, :), boundary_edges(id_xing, 3:4) ];
                    boundary_edges(id_xing+1:end, :)];
            end
            %             fprintf(1, '%d %d\n', id_poly, id_edge);
        end
    end
end
%%% Merge dublicated points
edge_length = edgeLength(boundary_edges);
flt_edge_length = edge_length>10;
boundary_edges = boundary_edges(flt_edge_length, :);
environment.boundary.ring = mb.visilibity2boost(boundary_edges(:, 1:2));
environment.boundary.isplaceable = ones(1, size(environment.boundary.ring, 2));


%% Poses on Boundary vertices
% use combined environment to place because otherwise obstacles will prohibit
% ordinary placement
environment = Environment.combine(environment);
% boundary = environment.combined{1}(1);
% obstacles = environment.combined{1}(2:end);
boundary_corners = mb.ring2corners(environment.boundary.ring);
% boundary_corners = mb.ring2corners(boundary{1});
boundary_corners_selection = boundary_corners(:, environment.boundary.isplaceable);
boundary_corners_selection = boundary_corners;

%% Add intersections of obstacles with environment


sensor_poses_boundary = Discretization.Sensorspace.place_sensors_on_corners(boundary_corners_selection, sensor.directional(2), sensorspace.resolution.angular, false);

%% Poses on Mountable vertices
    if iscell(environment.mountable{1})
        mountable_corners = cellfun(@(x)mb.ring2corners(x{1}), environment.mountable, 'uniformoutput', false);
    else
        mountable_corners = cellfun(@(x)mb.ring2corners(x), environment.mountable, 'uniformoutput', false);
    end
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
[sensor_poses, vfovs, vm] = Discretization.Sensorspace.vfov(sensor_poses_in, environment, workspace_positions, options, true); % todo: remove spikes as option?

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
cellfun(@(p) mb.drawPoint(p(:,2), 'color', 'g'), vfovs)
% Discretization.Sensorspace.draw(sensor_poses_mountables, 'g');
% Discretization.Sensorspace.draw(sensor_poses_initial_in, 'r');
disp(npts);
% pause;
% end
%%
