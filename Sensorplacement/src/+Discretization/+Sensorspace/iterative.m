function [sensor_poses, vfovs, vm] = iterative(environment, sensor, workspace_positions, options)
%% ITERATIVE(environment, sensor, workspace_positions, options) samples the sensorspace
%    by edge splitting. Options 
% options.resolution.angular : angular resolution per vertex
% options.poses.additional : number of additional poses to the vertex poses
%
% Right now 2.6.14 the orientation of the environment is ccw for the outer boundary 
% and cw for the inner mountable rings, therfore the corners have to be processed
% in reverse order.
% bpolyclip
%% Poses on Boundary vertices
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

%%% check if points are in environment
environment = Environment.combine(environment);
[in_environment] = mb.inmultipolygon(environment.combined, int64(sensor_poses_initial(1:2,:)));
%%% check distance to polygon edges for every other point
vertices = environment.combined{1}{1};
dist_polygon_edges = mb.distancePoints(sensor_poses_initial(1:2,~in_environment), vertices);
dist_polygon_edges_min = min(dist_polygon_edges, [], 2);
in_environment(~in_environment) = dist_polygon_edges_min < 10;
sensor_poses_initial_in = sensor_poses_initial(:, in_environment);

% Discretization.Sensorspace.draw(sensor_poses_initial_in, 'm');
%% Add additional positions iterative
mountable_corners_flat = cell2mat(mountable_corners);
edges = [boundary_corners(1:4, :), mountable_corners_flat(1:4,:)];
edgelengths = sum(edges.^2, 1);
[~, idmax] = max(edgelengths);



return;
%% TEST
% close all; 
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

Environment.draw(environment);

Discretization.Sensorspace.draw(sensor_poses_boundary);
Discretization.Sensorspace.draw(sensor_poses_mountables, 'g');
Discretization.Sensorspace.draw(sensor_poses_initial_in, 'r');

%%
sensor_poses.problem.S = [];
%sample walls and each mountable boundary independently
sensor_positions_wAngles = {};
%%
if sensor_poses.sensorspace.uniform_position_distance <= 0
    error('pc.sensorspace.uniform_position_distance must be > 0');
end

upd = sensor_poses.sensorspace.uniform_position_distance;
for idply = 1:numel(mountable)
    %%
    % using of linspace makes sure that every edge is spaced
    edges = mb.polygonGeomEdges(mountable{idply});
    edge_lengths =  mb.edgeLength(edges);
    % add one additional point in order to compensate rounding errors
%     num_edge_points = edge_lengths./pc.sensorspace.uniform_position_distance + int64(1);
    num_sampled_points = edge_lengths./10 + int64(1);
    
    sensor_positions_ring = {};
    %%
    for idedge = 1:size(edges, 1)
        spr = [int64(linspace(double(edges(idedge, 1)), double(edges(idedge, 3)),num_sampled_points(idedge)));...
            int64(linspace(double(edges(idedge, 2)), double(edges(idedge, 4)),num_sampled_points(idedge)))]';
        % filter sensor positions for obstacles and then remove all < dmax
        other_mountables = mountable([2:idply-1 idply+1:numel(mountable)]);
        if ~isempty(other_mountables) && ~isempty(environment.obstacles.poly)
            [in] = binpolygon(spr', environment.obstacles.poly) | binpolygon(spr', other_mountables);
        elseif ~isempty(environment.obstacles.poly)
            [in] = binpolygon(spr', environment.obstacles.poly);
        else
            in = false(size(spr,1),1);
        end
       % %% DEBUG
%         drawPoint(spr(in,:),'or')
%         drawPoint(spr(~in,:),'ok')
%%
        spr = spr(~in, :);
        %%%
        lin_dist_2_spr = sqrt(sum((spr(1:end-1,:)-spr(2:end,:)).^2, 2));
        
        flt = false(size(spr,1), 1);
        ids = 1;
%         flt(ids) = true; % 
        while ids <= size(spr,1)
            flt(ids) = true; %always true for ids = 1; chooses sensor if in sensor array
            lin_dist_csum = cumsum(lin_dist_2_spr(ids:end));
            ids = ids+sum(lin_dist_csum<upd)+1;            
        end
        %%
        if ~isempty(flt)
            flt(end) = true;
         %      %% 
                sensor_positions_ring{end+1} = spr(flt,:);
                num_edge_points(idedge) = sum(flt);
        else
            sensor_positions_ring{end+1} = [];
            num_edge_points(idedge) = 0;
        end
    end
    
    %%
    if sensor_poses.sensorspace.angles_sampling_occurence == sensor_poses.sensorspace.angles_sampling_occurences.within
        angles = cell(1,size(sensor_positions_ring, 1));
        for idpt = 1:size(sensor_positions_ring, 1);
            angles{idpt} = sensorspace_angles(sensor_poses);
        end
        error('mapping angles not implemented');
    else
        % map angles to points
        sensor_angles_ring_edges = mod(bsxfun(@plus, sensor_poses.sensorspace.angles, mb.angle2points(edges)), 2*pi);
        num_angles_per_position = size(sensor_angles_ring_edges, 2);
        replicate_positions_for_angles_function = @(x) repmat(x, num_angles_per_position, 1);
        %
        for idedge = 1:size(edges, 1)
            replicated_positions = arrayfun(replicate_positions_for_angles_function, sensor_positions_ring{idedge}, 'UniformOutput', false);
            replicated_positions = double(cell2mat(replicated_positions));
            sensor_positions_wAngles{end+1} = [replicated_positions, repmat(sensor_angles_ring_edges(idedge,:)', num_edge_points(idedge), 1)]';
        end
    end
    
end
sensor_poses.problem.S = cell2mat(sensor_positions_wAngles(~cellfun(@isempty, sensor_positions_wAngles)));

%%



if sensor_poses.sensorspace.angles_sampling_occurence == sensor_poses.sensorspace.angles_sampling_occurences.pre
    %%
      sensor_poses.sensorspace.angles = sensorspace.angles(sensor_poses);
end

switch sensor_poses.sensorspace.position_sampling_technique
    case sensor_poses.common.sampling_techniques.random
        error('not yet converted to new format');
%         pc = generate_random_sensorspace_positions(pc);
    case sensor_poses.common.sampling_techniques.uniform
        %%
        sensor_poses = sensorspace.uniform_positions(sensor_poses);
    otherwise
        error('not implemented');
end
%% remove positions that are outside of workspace
% in_workspace = binpolygon(int64(pc.problem.S(1:2, :)), pc.environment.boundary.ring, pc.common.grid_limit);
% write_log('Removed %d of %d sensor positions that are not in or on workspace', sum(~in_workspace) ,numel(in_workspace));
% % mb.drawPoint(pc.problem.S(:, ~in_workspace),'og');
% pc.problem.S = pc.problem.S(:, in_workspace);

%% verbose
%h_pts = mb.drawPoint(pc.problem.S(1:2, :));
% h_pts = mb.drawPoint(pc.problem.S(1:2, ~in_workspace));
% delete(h_pts)


%% remove positions that are 'on' obstacles
if ~isempty(environment.obstacles.poly)
in_obstacle = binpolygon(int64(sensor_poses.problem.S(1:2,:)), environment.obstacles.poly);
write_log('Removed %d of %d sensor positions in obstacles', sum(in_obstacle), numel(in_obstacle));
% mb.drawPoint(pc.problem.S(:, in_obstacle),'ob');
sensor_poses.problem.S = sensor_poses.problem.S(:, ~in_obstacle);
end

%% verbose
%h_pts = mb.drawPoint(pc.problem.S(1:2, :));
% h_pts = mb.drawPoint(pc.problem.S(1:2, in_obstacle));
% delete(h_pts)

%% remove dublicate positions and positions within snap distance if they exist and sort positions by x, y, phi
[S_unique, ~, u_p_ic] = unique(sensor_poses.problem.S', 'rows', 'sorted');
%%% remove positions within snap distance
[unique_positions, ~, u_p_ic] = unique(S_unique(:,1:2), 'rows', 'stable');
S_flt_dist = sqrt(sum(diff([-inf(1,2);unique_positions], 1, 1).^2, 2))<=sensor_poses.common.snap_distance;
s1 = find(S_flt_dist)-1;
s2 = find(S_flt_dist);
% dall = distancePoints(unique_positions, unique_positions);
% id_merge = find(triu(dall,1) > 0 & triu(dall,1) <= pc.common.snap_distance);
% [s1, s2] = ind2sub(size(dall), id_merge);
%%%
for ids = 1:numel(s1)
    ids_s1 = find(u_p_ic==s1(ids));
    ids_s2 = find(u_p_ic==s2(ids));
    pos_merge = round((S_unique(ids_s1(1), 1:2)+S_unique(ids_s2(1), 1:2))/2);
    S_unique([ids_s1; ids_s2],1) = pos_merge(1);
    S_unique([ids_s1; ids_s2],2) = pos_merge(2);
end
write_log('Removed %d sensor positions within snap distance', numel(s1));
%%
sensor_poses.problem.S = unique(S_unique, 'rows', 'sorted')';
write_log('Removed %d dublicated sensor positions', size(S_unique, 1)-size(sensor_poses.problem.S, 2));

%% remove positions with an angular distance that is too close
S_flt_dist = abs(sum(diff([-inf(3,1) ,sensor_poses.problem.S], 1, 2), 1))<=sensor_poses.sensorspace.min_angle_distance;
write_log('Removed %d of %d sensor positions with too close angular distances', sum(S_flt_dist), numel(S_flt_dist));
sensor_poses.problem.S = sensor_poses.problem.S(:, ~S_flt_dist);

%% verbose
%h_pts = mb.drawPoint(pc.problem.S(1:2, :));
%h_pts = mb.drawPoint(pc.problem.S(1:2, S_flt_dist));
% delete(h_pts)



%%
sensor_poses.sensorspace.number_of_angles_per_position = numel(sensor_poses.sensorspace.angles);
sensor_poses.problem.num_sensors = size(sensor_poses.problem.S, 2);
% pc.problem.num_sensors = pc.problem.num_sensors;
sensor_poses.problem.t_sum = numel(sensor_poses.sensors);
sensor_poses.problem.num_sensorpositions = size(unique(sensor_poses.problem.S(1:2,:)', 'rows'),1);
sensor_poses.problem.St_i = zeros(sensor_poses.problem.num_sensors, sensor_poses.problem.t_sum);

% prerequisite fullfiled
sensor_poses.progress.sensorspace.positions = true;