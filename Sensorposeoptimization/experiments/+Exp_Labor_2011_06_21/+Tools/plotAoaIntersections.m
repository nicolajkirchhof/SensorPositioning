function plotAoaIntersections( sensor_pose, aoas )
%PLOTPIXVAL2D Summary of this function goes here
%   Detailed explanation goes here


cla;
hold on;

num_sensors = numel(sensor_pose);
colors = hsv(num_sensors);
pixlist = {};

pixfov = Mltools.deg2rad(6);
pixel_variance = Mltools.deg2rad(8);
position_variance = [0 0 0.25 0.25 0.25 0.25 0.25 0.25];
position_variance_dist = sqrt(2*(position_variance.*position_variance));
% sqrt(position_variance^2+position_variance^2);
orientation_offset = Mltools.deg2rad(67.5);
pixgeom = [1 16];
aoa_length = 10;
aoa_variance = 0.1;

calcPositionOffset = @(x, y, phi, r) [x+cos(phi)*r, y+sin(phi)*r];
polygons = {};
idx_polygons = 1;
for idx_sensor = 1:2:num_sensors
    idx_pixlist = 1;
    % SG filter hack
    
    % sensor properties
    sens_rot1 = sensor_pose{idx_sensor}.Orientation(3);
    sens_rot2 = sensor_pose{idx_sensor+1}.Orientation(3);
    sens_transX = sensor_pose{idx_sensor}.Position(1);
    sens_transY = sensor_pose{idx_sensor}.Position(2);
    
    sens_aoas1 = aoas{idx_sensor};
    sens_aoas2 = aoas{idx_sensor+1};
    
    
    if position_variance(idx_sensor) > 0
        rectangle('Position',[sens_transX-position_variance(idx_sensor),sens_transY-position_variance(idx_sensor),position_variance(idx_sensor)*2,position_variance(idx_sensor)*2])
    end
%     sensivity_length = 10; % 5m
    
    %
    pmax = calcPositionOffset(sens_transX, sens_transY, (sens_rot1+orientation_offset), position_variance_dist(idx_sensor));
    pmin = calcPositionOffset(sens_transX, sens_transY, (sens_rot2-orientation_offset), position_variance_dist(idx_sensor));
    
    plot(sens_transX, sens_transY, 'o');
    plot(pmax(1) ,pmax(2), 'o');
    plot(pmin(1), pmin(2), 'o');
    axis([-4 0.5 0 5]);
  
    % create sensor sensor_pixelcones arcs
%     sensor_pixelcones = {};
%     sensor_filled_cones = {};
%     count_pixelcones = 1;
%     conesave = [];
    
    
    for idx_aoa1 = 1:numel(sens_aoas1)
        aoa1_pmax = calcPositionOffset(pmax(1), pmax(2), (sens_rot1+sens_aoas1(idx_aoa1)+aoa_variance), aoa_length);
        aoa1_pmin = calcPositionOffset(pmin(1), pmin(2), (sens_rot1+sens_aoas1(idx_aoa1)-aoa_variance), aoa_length);
        geom2d.drawLine(geom2d.createLine(pmax, aoa1_pmax));
        geom2d.drawLine(geom2d.createLine(pmin, aoa1_pmin));
        polygons{idx_polygons} = [aoa1_pmax; pmax; pmin; aoa1_pmin];
        idx_polygons = idx_polygons+1;
    end
    for idx_aoa2 = 1:numel(sens_aoas2)
        aoa2_pmax = calcPositionOffset(pmax(1), pmax(2), (sens_rot2+sens_aoas2(idx_aoa2)+aoa_variance), aoa_length);
        aoa2_pmin = calcPositionOffset(pmin(1), pmin(2), (sens_rot2+sens_aoas2(idx_aoa2)-aoa_variance), aoa_length);
        geom2d.drawLine(geom2d.createLine(pmax, aoa2_pmax), 'color', 'k');
        geom2d.drawLine(geom2d.createLine(pmin, aoa2_pmin), 'color', 'k');
        polygons{idx_polygons} = [aoa2_pmax; pmax;  pmin; aoa2_pmin];
        idx_polygons = idx_polygons+1;
    end
end

%intersect_polygon = polygons{1};
for idx_polygons = 1:numel(polygons)
    S(idx_polygons).P(1).x = polygons{idx_polygons}(:,1)';
    S(idx_polygons).P(1).y = polygons{idx_polygons}(:,2)';
    S(idx_polygons).P(1).hole = 0;
end
Geo = Polygons_intersection(S,0,1e-8);
intersect_polygon = Geo(end).P;
geom2d.fillPolygon(intersect_polygon.x', intersect_polygon.y');



end

