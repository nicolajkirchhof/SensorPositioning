function [valid_sensor_poses, vfov_rings, sp_wpn_visibilities] = vfov(sensor_poses, environment, workspace_positions, discretization)
%% VFOV(sensor_poses, environment, discretization) calculates the vfov of one 
%   ore multiple sensors
%   
valid_sensor_poses = [];
vfov_rings = {};
sp_wpn_visibilities = [];
if isempty(sensor_poses) || isempty(environment)
    return;
end

write_log(' calculating visibilities:');
sensor = discretization.sensor;
sensorspace = discretization.sensorspace;
environment = Environment.combine(environment);
%%% remove sensor positions that are not in polygon
bpolyclip_options = Configurations.Bpolyclip.environment;
bpolyclip_batch_options = Configurations.Bpolyclip.combine(bpolyclip_options, true);
visilibity_options = {bpolyclip_options.spike_distance, bpolyclip_options.spike_distance, bpolyclip_options.verbose};
[unique_positions, ~, u_p_ic] = unique(sensor_poses(1:2,:)', 'rows', 'stable');
%%%
vis_polys = visilibity(unique_positions', environment.combined, visilibity_options{:});
vis_empty_flt = cellfun(@isempty, vis_polys);
vis_flt = any(cell2mat(arrayfun(@(id) u_p_ic==id, find(vis_empty_flt), 'uniformoutput', false)),2);
% correction if none is filtered
if isempty(vis_flt)
    vis_flt = false(size(u_p_ic));
end
write_log('number of polys neglected because they are not in polygon %d\n',  sum(vis_flt));
%%%
vis_polys = cellfun(@int64, vis_polys(~vis_empty_flt), 'uniformoutput', false);
sensor_poses = sensor_poses(:, ~vis_flt);
u_p_ic = u_p_ic(~vis_flt);
%%%
% calculates the sensor fov, the inner ring is defined by the min distance and the outer ring by 
% the max distance. Since both rings have the same orientation, the inner is flipped to get a 
% polygon
default_annulus = mb.createAnnulusSegment(0,0,sensor.distance(1), sensor.distance(2), 0, sensor.fov, sensorspace.ringvertices);
fun_sensorfov = @(x,y,theta) int64(bsxfun(@plus, ([cos(theta) -sin(theta); sin(theta)  cos(theta)]*default_annulus), [x;y]));
sensor_fovs = arrayfun(fun_sensorfov, sensor_poses(1,:), sensor_poses(2,:), sensor_poses(3,:), 'uniformoutput', false);

combined_polys = [vis_polys, sensor_fovs];
% combine vis_polys and sensor_fovs to use batch processing
poly_combine_jobs = mat2cell([numel(vis_polys)+(1:numel(sensor_fovs)); u_p_ic']', ones(numel(sensor_fovs),1), 2);
%%%
[sensor_visibility_polygons, sensor_visibility_polygon_areas] = bpolyclip_batch(combined_polys, 1, poly_combine_jobs, bpolyclip_batch_options );
small_polys = sensor_visibility_polygon_areas < sensor.area(1);
write_log('number of polys neglected because of area %d\n',  sum(small_polys));
sensor_visibility_polygons = sensor_visibility_polygons(~small_polys);
sensorpositions_filtered = sensor_poses(:, ~small_polys);
%%%
% check all points against all visibility polygons
fun_binpolygon = @(poly) binpolygon(int64(workspace_positions(1:2,:)), poly); 
svp_empty = cellfun(@isempty, sensor_visibility_polygons);
sensor_point_visibilities = cell2mat(cellfun(fun_binpolygon, sensor_visibility_polygons(~svp_empty), 'uniformoutput', false)')';
%%%
empty_visibilities = sum(sensor_point_visibilities,1) == 0;
write_log('number of polys neglected because of visibility %d\n', sum(empty_visibilities));
%%% calculate filtered vectors
vfov_rings = sensor_visibility_polygons(~empty_visibilities);
sp_wpn_visibilities = sensor_point_visibilities(:, ~empty_visibilities)';
valid_sensor_poses = sensorpositions_filtered(:, ~empty_visibilities);
write_log('...done ');

%%
return;
%% TESTING
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



%%% Poses on Boundary vertices
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
% sensor_poses = sensor_poses_initial;
%%% check if points are in environment
environment = Environment.combine(environment);
[in_environment] = mb.inmultipolygon(environment.combined, int64(sensor_poses_initial(1:2,:)));
%%% check distance to polygon edges for every other point
vertices = environment.combined{1}{1};
dist_polygon_edges = mb.distancePoints(sensor_poses_initial(1:2,~in_environment), vertices);
dist_polygon_edges_min = min(dist_polygon_edges, [], 2);
in_environment(~in_environment) = dist_polygon_edges_min < 10;
sensor_poses = sensor_poses_initial(:, in_environment);

%%%
[valid_sensor_poses, vfov_rings, sp_wpn_visibilities] = Discretization.Sensorspace.vfov(sensor_poses, environment, workspace_positions, discretization);
%%
cla,
for idv = 1:numel(vfov_rings)
Environment.draw(environment);
hold on;
Discretization.Sensorspace.draw(valid_sensor_poses(:, idv));
mb.drawPolygon(vfov_rings(idv));
pause;
end
%%
Discretization.Sensorspace.draw(valid_sensor_poses);


