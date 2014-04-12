function plotIterativeSensorState( S )
%PLOTITERATIVESENSORSTATE Summary of this function goes here
%   Detailed explanation goes here
%%
figure;
cla, hold on;
for idx_sensor = 1:numel(S.sensorBoundPolygons)*2
idx_S = ceil(idx_sensor/2);
    geom2d.drawPolygon(S.sensorBoundPolygons{idx_S},'r');
    mean_sensor_angle = mean(S.sensorAoaBounds{idx_sensor});
    ray_aoaMean_center = geom2d.createRay(S.sensorBoundPolygonCenters{idx_S}, mean_sensor_angle);
    twopoints_center = [S.sensorBoundPolygonCenters{idx_S}; geom2d.pointOnLine(ray_aoaMean_center, 1)];
    top_poly = cutpolygon.cutpolygon(S.sensorBoundPolygons{idx_S}, twopoints_center, 1, false, false);
    bottom_poly = cutpolygon.cutpolygon(S.sensorBoundPolygons{idx_S}, twopoints_center, 2, false, false);
        
    dist_ray_bottom = geom2d.distancePointLine(bottom_poly, ray_aoaMean_center);
        dist_ray_top = geom2d.distancePointLine(top_poly, ray_aoaMean_center);
        
        p_max_bottom = bottom_poly(find(max(dist_ray_bottom)==dist_ray_bottom, 1, 'first'), :);
        p_max_top = top_poly(find(max(dist_ray_top)==dist_ray_top, 1, 'first'), :);
        % test to find right min max configuration
        %%
        
        
        for idx_conf = 1:2
            ray_bottom{idx_conf} = geom2d.createRay(p_max_bottom, S.sensorAoaBounds{idx_sensor}(idx_conf));
            ray_top{idx_conf} = geom2d.createRay(p_max_top, S.sensorAoaBounds{idx_sensor}(3-idx_conf));
            point_ray_bottom{idx_conf} = geom2d.pointOnLine(ray_bottom{idx_conf}, 3);
            point_ray_top{idx_conf} = geom2d.pointOnLine(ray_top{idx_conf}, 3);
            poly_unsorted = [p_max_bottom; p_max_top; point_ray_top{idx_conf}; point_ray_bottom{idx_conf}];
            poly_centroid = geom2d.centroid(poly_unsorted);
            poly{idx_conf} = geom2d.angleSort(poly_unsorted, poly_centroid);
            poly{idx_conf}(end+1, :) = poly{idx_conf}(1,:);
            %             geom2d.drawPolygon(poly{idx_conf});
            area(idx_conf) = geom2d.polygonArea(poly{idx_conf});
            %
        end
        
         idx_max_area = find(max(area)==area);
      geom2d.drawPolygon(poly{idx_max_area},'g');
end

