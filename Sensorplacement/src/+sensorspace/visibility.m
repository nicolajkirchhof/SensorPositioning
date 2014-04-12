function pc = visibility(pc)
%% calculates the sensor visibility matrix xt_ij. Therefore the sensorposes and workspace positions 
% have to be calculated in advance as well as the environment representation
write_log(' calculating visibility...');
if ~pc.progress.environment.load
    pc = environment.load(pc);
end
if ~pc.progress.environment.combine
    pc = environment.combine(pc);
end
if ~pc.progress.workspace.positions
    pc = workspace.positions(pc);
end
if ~pc.progress.sensorspace.positions
    pc = sensorspace.positions(pc);
end
%%%
% boost_visible_poly_tmp = bpolyclip(pc.environment.walls.ring, pc.environment.obstacles.poly, 0, 1, pc.common.snap_distance);
% boost_visible_poly = bpolyclip(boost_visible_poly_tmp, pc.environment.mountable.poly, 0, 1, pc.common.snap_distance);
% cla, mb.drawPolygon(boost_visible_poly)
boost_visible_poly = pc.environment.combined.poly;
%%%
% vpoly = mb.boost2visilibity(boost_visible_poly);
%%% remove sensor positions that are not in polygon
% in_ply = binpolygon(int64(pc.problem.S(1:2,:)), boost_visible_poly);
% write_log('removed %d sensorpositions that are not in the environment', sum(~in_ply));
% mb.drawPoint(pc.problem.S(:, ~in_ply),'og');
% S_inply = pc.problem.S(:, in_ply);
S_inply = pc.problem.S;
%%%
[unique_positions, ~, u_p_ic] = unique(S_inply(1:2,:)', 'rows', 'stable');
%%
vis_polys = visilibity(unique_positions', boost_visible_poly, pc.common.snap_distance, pc.common.snap_distance, pc.common.verbose);
vis_empty_flt = cellfun(@isempty, vis_polys);
vis_flt = any(cell2mat(arrayfun(@(id) u_p_ic==id, find(vis_empty_flt), 'uniformoutput', false)),2);
% correction if none is filtered
if isempty(vis_flt)
    vis_flt = false(size(u_p_ic));
end
write_log('number of polys neglected because they are not in polygon %d',  sum(vis_flt));
%%
vis_polys = cellfun(@int64, vis_polys(~vis_empty_flt), 'uniformoutput', false);
S_inply = S_inply(:, ~vis_flt);
u_p_ic = u_p_ic(~vis_flt);
%%
% calculates the sensor fov, the inner ring is defined by the min distance and the outer ring by 
% the max distance. Since both rings have the same orientation, the inner is flipped to get a 
% polygon
% fun_createCircleArc = @(x,y,phi,dist) unique(circleArcToPolyline([[x y], dist, rad2deg(phi), pc.sensors.fov], pc.common.polyline_verticies), 'rows', 'stable')';
% fun_closePolygon = @(poly) [poly,poly(:,1)];
% fun_sensorfov = @(x,y,phi) int64(fun_closePolygon([fliplr(fun_createCircleArc(x,y,phi,pc.sensors.distance.min)), fun_createCircleArc(x,y,phi,pc.sensors.distance.max)]));
default_annulus = mb.createAnnulusSegment(0,0,pc.sensors.distance.min, pc.sensors.distance.max, 0, pc.sensors.fov, pc.common.polyline_verticies);
fun_sensorfov = @(x,y,theta) int64(bsxfun(@plus, ([cos(theta) -sin(theta); sin(theta)  cos(theta)]*default_annulus), [x;y]));
sensor_fovs = arrayfun(fun_sensorfov, S_inply(1,:), S_inply(2,:), S_inply(3,:), 'uniformoutput', false);

combined_polys = [vis_polys, sensor_fovs];
% combine vis_polys and sensor_fovs to use batch processing
poly_combine_jobs = mat2cell([numel(vis_polys)+(1:numel(sensor_fovs)); u_p_ic']', ones(numel(sensor_fovs),1), 2);
%%
[sensor_visibility_polygons, sensor_visibility_polygon_areas] = bpolyclip_batch(combined_polys, 1, poly_combine_jobs, pc.common.bpolyclip_batch_options );
small_polys = sensor_visibility_polygon_areas < pc.sensorspace.min_visible_area;
write_log('number of polys neglected because of area %d',  sum(small_polys));
sensor_visibility_polygons = sensor_visibility_polygons(~small_polys);
% sensor_fovs = sensor_fovs(~small_polys);
% sensor_visibility_polygon_areas = sensor_visibility_polygon_areas(~small_polys);
sensorpositions_filtered = S_inply(:, ~small_polys);
pc.problem.num_sensors = sum(~small_polys);
%%
% check all points against all visibility polygons
fun_binpolygon = @(poly) binpolygon(int64(pc.problem.W(1:2,:)), poly); 
svp_empty = cellfun(@isempty, sensor_visibility_polygons);
sensor_point_visibilities = cellfun(fun_binpolygon, sensor_visibility_polygons(~svp_empty), 'uniformoutput', false);
svp_vis = false(1, pc.problem.num_positions);
spv = cell(1, pc.problem.num_sensors);
spv(svp_empty) = {false(1, pc.problem.num_positions)};
spv(~svp_empty) = sensor_point_visibilities;
%%
% filter visibility polygons with no points in them
sensor_point_visibilities = cell2mat(spv');
if pc.sensorspace.min_visible_positions>0
empty_visibilities = sum(sensor_point_visibilities,2) < pc.sensorspace.min_visible_positions;
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
pc.problem.V = sensor_visibility_polygons;
pc.problem.S = sensorpositions_filtered;

%% only if necessary for saving
% pc.problem.xt_ij = sparse(sensor_point_visibilities);
pc.problem.xt_ij = sensor_point_visibilities;
% spv_cell = mat2cell(sensor_point_visibilities, size(sensor_point_visibilities,1), ones(size(sensor_point_visibilities,2),1));
% pc.problem.wp_s_idx = cellfun(@find, spv_cell, 'uniformoutput', false);
pc.problem.wp_s_idx = mat2cell(sensor_point_visibilities, size(sensor_point_visibilities,1), ones(size(sensor_point_visibilities,2),1));
pc.problem.num_sensors = numel(pc.problem.V); % = size(pc.problem.S, 2) = size(pc.problem.xt_ij, 1);
% pc.sensorspace.extra.vis_polys_cutted = [];
pc.problem.num_sensorpositions = size(unique(pc.problem.S(1:2,:)', 'rows'),1);
pc.environment.visible_polygon = boost_visible_poly;
% pc.sensorspace.sensorposes.polys = sensor_fovs;
% prerequisit fulfilled
pc.progress.sensorspace.visibility = true;
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
% pc.environment.file =  'res/floorplans/NicoLivingroom_NoObstacles.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangle.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithHole.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithThreeHoles.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithObstacles.dxf';
% pc.environment.file = 'res/env/rectangle4x4.environment';
% pc.environment.file = 'res/env/simple_poly10_2.environment';
% pc.environment.file = 'res/env/simple_poly10_8.environment';
% pc.environment.file = 'res/env/simple_poly30_52.environment';
pc = processing_configuration('P1_Pool_2Offices');
% pc.environment.file = 'res/floorplans/P1-Pool.dxf';
pc.environment.file = 'res/floorplans/P1-01-EtPart.dxf';
pc.sensorspace.uniform_position_distance = 500;
pc.sensorspace.uniform_angle_distance = deg2rad(45);
pc.workspace.grid_position_distance = 500;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc.sensors.quality.distance.max = 2000/pc.sensors.distance.max;



