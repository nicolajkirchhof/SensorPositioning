function vfov_ring = vfov(sensor_poses, environment, workspace_positions, discretization)
%% VFOV(sensor_poses, environment, discretization) calculates the vfov of one 
%   ore multiple sensors
%   

sensor = discretization.sensor;
sensorspace = discretization.sensorspace;
workspace = discretization.workspace;
% boost_visible_poly_tmp = bpolyclip(environment.walls.ring, environment.obstacles.poly, 0, 1, snap_distance);
% boost_visible_poly = bpolyclip(boost_visible_poly_tmp, environment.mountable.poly, 0, 1, snap_distance);
% cla, mb.drawPolygon(boost_visible_poly)
environment = Environment.combine(environment);
%%%
% vpoly = mb.boost2visilibity(boost_visible_poly);
%%% remove sensor positions that are not in polygon
% in_ply = binpolygon(int64(problem.S(1:2,:)), boost_visible_poly);
% write_log('removed %d sensorpositions that are not in the environment', sum(~in_ply));
% mb.drawPoint(problem.S(:, ~in_ply),'og');
% S_inply = problem.S(:, in_ply);
% sensor_poses = problem.S;
%%%
bpolyclip_options = Configurations.Bpolyclip.environment;
bpolyclip_batch_options = Configurations.Bpolyclip.combine(bpolyclip_options, true);
visilibity_options = {bpolyclip_options.grid_limit, bpolyclip_options.spike_distance, bpolyclip_options.verbose};
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
% fun_createCircleArc = @(x,y,phi,dist) unique(circleArcToPolyline([[x y], dist, rad2deg(phi), sensor.fov], polyline_verticies), 'rows', 'stable')';
% fun_closePolygon = @(poly) [poly,poly(:,1)];
% fun_sensorfov = @(x,y,phi) int64(fun_closePolygon([fliplr(fun_createCircleArc(x,y,phi,sensor.distance.min)), fun_createCircleArc(x,y,phi,sensor.distance.max)]));
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
% sensor_fovs = sensor_fovs(~small_polys);
% sensor_visibility_polygon_areas = sensor_visibility_polygon_areas(~small_polys);
sensorpositions_filtered = sensor_poses(:, ~small_polys);
num_sensors = sum(~small_polys);
%%%
% check all points against all visibility polygons
fun_binpolygon = @(poly) binpolygon(int64(workspace_positions(1:2,:)), poly); 
svp_empty = cellfun(@isempty, sensor_visibility_polygons);
sensor_point_visibilities = cellfun(fun_binpolygon, sensor_visibility_polygons(~svp_empty), 'uniformoutput', false);
svp_vis = false(1, size(workspace_positions, 2));
spv = cell(1, num_sensors);
spv(svp_empty) = {false(1, size(workspace_positions, 2))};
spv(~svp_empty) = sensor_point_visibilities;
%%
% filter visibility polygons with no points in them
sensor_point_visibilities = cell2mat(spv');
if sensorspace.min_visible_positions>0
empty_visibilities = sum(sensor_point_visibilities,2) < sensorspace.min_visible_positions;
write_log('number of polys neglected because of visibility %d', sum(empty_visibilities));
%% calculate filtered vectors
sensor_visibility_polygons = sensor_visibility_polygons(~empty_visibilities);
sensor_point_visibilities = sensor_point_visibilities(~empty_visibilities, :);
sensorpositions_filtered = sensorpositions_filtered(:, ~empty_visibilities);
% sensor_fovs = sensor_fovs(~empty_visibilities);
end
% sensor_visibility_polygon_areas = sensor_visibility_polygon_areas(~empty_visibilities);
% visibility_polygon_lengths = cellfun(@mb.polygonLength, sensor_visibility_polygons);

%%
problem.V = sensor_visibility_polygons;
problem.S = sensorpositions_filtered;

%% only if necessary for saving
% problem.xt_ij = sparse(sensor_point_visibilities);
problem.xt_ij = sensor_point_visibilities;
% spv_cell = mat2cell(sensor_point_visibilities, size(sensor_point_visibilities,1), ones(size(sensor_point_visibilities,2),1));
% workspace_positionsp_s_idx = cellfun(@find, spv_cell, 'uniformoutput', false);
workspace_positionsp_s_idx = mat2cell(sensor_point_visibilities, size(sensor_point_visibilities,1), ones(size(sensor_point_visibilities,2),1));
num_sensors = numel(problem.V); % = size(problem.S, 2) = size(problem.xt_ij, 1);
% sensorspace.extra.vis_polys_cutted = [];
problem.num_sensorpositions = size(unique(problem.S(1:2,:)', 'rows'),1);
environment.visible_polygon = environment.combined;
% sensorspace.sensorposes.polys = sensor_fovs;
% prerequisit fulfilled
progress.sensorspace.visibility = true;
write_log('...done ');
% 
%%
% figure; plot(visibility_polygon_lengths)
% figure, plot(sensor_visibility_polygon_areas, 'r')
% figure, plot(visibility_polygon_lengths./sensor_visibility_polygon_areas, '.r')
% figure, plot(sensor_visibility_polygon_areas./visibility_polygon_lengths, '.r')
return;
%% TESTING
% function pc = run(pc)
% calculates the two coverage placement with and withoug distance, directional and combined
% constraints
% the following values will be adapted throughout the evaluation process
close all; clear all; fclose all;
% environment.file =  'res/floorplans/NicoLivingroom_NoObstacles.dxf';
% environment.file =  'res/floorplans/SimpleRectangle.dxf';
% environment.file =  'res/floorplans/SimpleRectangleWithHole.dxf';
% environment.file =  'res/floorplans/SimpleRectangleWithThreeHoles.dxf';
% environment.file =  'res/floorplans/SimpleRectangleWithObstacles.dxf';
% environment.file = 'res/env/rectangle4x4.environment';
% environment.file = 'res/env/simple_poly10_2.environment';
% environment.file = 'res/env/simple_poly10_8.environment';
% environment.file = 'res/env/simple_poly30_52.environment';
pc = processing_configuration('P1_Pool_2Offices');
% environment.file = 'res/floorplans/P1-Pool.dxf';
environment.file = 'res/floorplans/P1-01-EtPart.dxf';
sensorspace.uniform_position_distance = 500;
sensorspace.uniform_angle_distance = deg2rad(45);
workspace.grid_position_distance = 500;
sensor.distance.min = 0;
sensor.distance.max = 6000;
sensor.quality.distance.max = 2000/sensor.distance.max;



