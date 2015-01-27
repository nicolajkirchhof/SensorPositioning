function [sensor_poses] = place_sensors_on_corners(corners, dirrange, resolution, clockwise, only_convex, only_reflex)
%% PLACE_SENSORS_ON_CORNERS(corners, dirrange, resolution, clockwise) 
%   calculates the sensor poses on the corners. Options:
% corners    : the corners as [6, n]
% dirrange   : the directional range in rad
% resolution : the angular resolution in rad
% clockwise  : true if the orientation is given in clockwise direction
if nargin < 6; only_reflex = false; end
%% Poses on Boundary vertices
p1 = double(corners(:, 1:2));
p2 = double(corners(:, 3:4));
p3 = double(corners(:, 5:6));
if clockwise 
    corner_angles = angle3Points(p1, p2, p3);
    corner_edge_angles = [angle2Points(p2, p1), angle2Points(p2, p3)];
else
    corner_angles = angle3Points(p3, p2, p1);
    corner_edge_angles = [angle2Points(p2, p3), angle2Points(p2, p1)];
end
if only_convex 
flt_convex = corner_angles <= pi;
corner_angles = corner_angles(flt_convex, :);
corner_edge_angles = corner_edge_angles(flt_convex, :);
% p1 = p1(flt_convex, :);
p2 = p2(flt_convex, :);
% p3 = p3(flt_convex, :);
end
if only_reflex
flt_convex = corner_angles > pi;
corner_angles = corner_angles(flt_convex, :);
corner_edge_angles = corner_edge_angles(flt_convex, :);
% p1 = p1(flt_convex, :);
p2 = p2(flt_convex, :);
% p3 = p3(flt_convex, :);
end

%%
sensors_per_corner = ceil((corner_angles-dirrange)./resolution);

last_sensor_angles = mod(corner_edge_angles(:,2)-dirrange, 2*pi);
first_sensor_angles = arrayfun(@(afirst, numang) afirst+(0:numang-1)*resolution, corner_edge_angles(:,1), sensors_per_corner, 'uniformoutput', false);
all_sensor_angles = arrayfun(@(firsts, last) [firsts{1}, last] , first_sensor_angles, last_sensor_angles, 'uniformoutput', false);

sensor_poses_cell = arrayfun(@(x, y, angles) [repmat([x;y], size(angles{1}));angles{1}], p2(:,1), p2(:,2), all_sensor_angles, 'uniformoutput', false);
sensor_poses = cell2mat(sensor_poses_cell');
return;
%% TEST boundary
cla;
corners = mb.ring2corners([ 3844, 1555, 1555, 1000, 344, 3844, 3844; 8312, 8312, 4500, 4500, 1200, 1200,  8312]);
tpl = Configurations.Sensor.tpl;
dirrange = tpl.directional(2);
sit = Configurations.Sensorspace.iterative;
resolution = sit.resolution.angular;
spbnd = Discretization.Sensorspace.place_sensors_on_corners(corners, dirrange, resolution, false);

Discretization.Sensorspace.drawSensorPose(spbnd);

%% TEST mountable
corners = mb.ring2corners([ 3011, 3511, 3511, 3011, 3011 ; 7393, 7393, 7937, 7937, 7393 ]);
tpl = Configurations.Sensor.tpl;
dirrange = tpl.directional(2);
sit = Configurations.Sensorspace.iterative;
resolution = sit.resolution.angular;
sp = Discretization.Sensorspace.place_sensors_on_corners(corners, dirrange, resolution, true);
Discretization.Sensorspace.drawSensorPose(sp);