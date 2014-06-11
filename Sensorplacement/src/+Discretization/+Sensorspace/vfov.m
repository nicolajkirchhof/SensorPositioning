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
bpolyclip_options = Configurations.Bpolyclip.vfov;
bpolyclip_batch_options = Configurations.Bpolyclip.combine(bpolyclip_options, true);
visilibity_options = Configurations.Visilibity.combine(Configurations.Visilibity.vfov);
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
%%
small_polys = sensor_visibility_polygon_areas < sensor.area(1);
write_log('number of polys neglected because of area %d\n',  sum(small_polys));
sensor_visibility_polygons = sensor_visibility_polygons(~small_polys);
sensorpositions_filtered = sensor_poses(:, ~small_polys);
%%% merge points and remove spikes
fun_spike = @(poly, center) mb.removePolygonAngularSpikes(poly, discretization.angularmerge, center);
fun_merge = @(poly, center) fun_spike(mb.mergePolygonPointsAngularDist(poly{1}{1}, discretization.angularmerge, center),center);
% fun_merge = @(p, c) fprintf('sz=%d %d %f %f %f\n', size(p{1}{1}), c);
sensorpositions_filtered_cell = mat2cell(sensorpositions_filtered, 3, ones(1, size(sensorpositions_filtered,2)));
sensor_visibility_polygons_merged = cellfun(fun_merge, sensor_visibility_polygons, sensorpositions_filtered_cell , 'uniformoutput', false);

% check all points against all visibility polygons
fun_binpolygon = @(poly) binpolygon(int64(workspace_positions(1:2,:)), poly); 
svp_empty = cellfun(@isempty, sensor_visibility_polygons_merged);
sensor_point_visibilities = cell2mat(cellfun(fun_binpolygon, sensor_visibility_polygons_merged(~svp_empty), 'uniformoutput', false)')';
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
%%%
% for npts = randi(800, 1, 20)
npts = 0;
options.sensorspace.poses.additional = npts;
%%%

%%%
[sensor_poses, vfovs, vm] = Discretization.Sensorspace.iterative(environment, workspace_positions, options);

Discretization.Sensorspace.draw(sensor_poses);
%%
cla
Environment.draw(environment, false); 
cellfun(@(p) mb.drawPoint(p{1}{1}(:,2), 'color', 'g'), vfovs);
%%
for i = 1:numel(vfovs)
    cla
Environment.draw(environment, false); 
mb.drawPolygon(vfovs(i));
disp(i);
pause;
end
% cellfun(@(p) mb.drawPolygon(p{1}{1}, 'color', 'g'), vfovs()
% Discretization.Sensorspace.draw(sensor_poses_mountables, 'g');
% Discretization.Sensorspace.draw(sensor_poses_initial_in, 'r');
disp(npts);
% pause;
% end
%%

