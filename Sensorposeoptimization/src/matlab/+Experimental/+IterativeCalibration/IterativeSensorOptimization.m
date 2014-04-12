function S = IterativeSensorOptimization(it_aoas, S, debug_level )
%PLOTPIXVAL2D Summary of this function goes here
%   Detailed explanation goes here
%%
DistanceCutRatio = 0.3;
MaxDistToGo = 0.5;
% calculate including surface
aoa_lines_lb = {};
aoa_lines_ub = {};
aoa_polys ={};
cnt = 1;
num_sensors = numel(it_aoas)/2;
configuration = zeros(num_sensors*2, 1);
for idx_sensor = 1:num_sensors*2
    for idx_aoa = 1:numel(it_aoas{idx_sensor})
        idx_S = ceil(idx_sensor/2);
        mean_sensor_angle = mean(S.sensorAoaBounds{idx_sensor});
        ray_aoaMean_center = geom2d.createRay(S.sensorBoundPolygonCenters{idx_S}, it_aoas{idx_sensor}(idx_aoa)+mean_sensor_angle);
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
            ray_bottom{idx_conf} = geom2d.createRay(p_max_bottom, S.sensorAoaBounds{idx_sensor}(idx_conf)+it_aoas{idx_sensor}(idx_aoa));
            ray_top{idx_conf} = geom2d.createRay(p_max_top, S.sensorAoaBounds{idx_sensor}(3-idx_conf)+it_aoas{idx_sensor}(idx_aoa));
            point_ray_bottom{idx_conf} = geom2d.pointOnLine(ray_bottom{idx_conf}, 10);
            point_ray_top{idx_conf} = geom2d.pointOnLine(ray_top{idx_conf}, 10);
            poly_unsorted{idx_conf} = [p_max_bottom; p_max_top; point_ray_top{idx_conf}; point_ray_bottom{idx_conf}];
            poly_centroid = geom2d.centroid(poly_unsorted{idx_conf});
            poly{idx_conf} = geom2d.angleSort(poly_unsorted{idx_conf}, poly_centroid);
            poly{idx_conf}(end+1, :) = poly{idx_conf}(1,:);
            %             geom2d.drawPolygon(poly{idx_conf});
            area(idx_conf) = geom2d.polygonArea(poly{idx_conf});
            %
            %% debug plot
            
        end
        if debug_level > 2
            figure, cla, hold on;
            geom2d.fillPolygon(poly{1}, 'y');
            geom2d.fillPolygon(poly{2}, 'b');
            geom2d.drawPolygon(poly_unsorted{1}, 'g');
            geom2d.drawPolygon(poly_unsorted{2}, 'r');
            
            geom2d.drawPoint(poly_centroid);
        end
        
        %%
        idx_max_area = find(max(area)==area);
        
        if idx_max_area == 1
            temp_aoa_ray{cnt, 1} = ray_bottom{idx_max_area};
            temp_aoa_ray{cnt, 2} = ray_top{idx_max_area};
        else
            temp_aoa_ray{cnt, 2} = ray_bottom{idx_max_area};
            temp_aoa_ray{cnt, 1} = ray_top{idx_max_area};
        end
        temp_polys(cnt).P(1).hole = 0;
        temp_polys(cnt).P(1).x = poly{idx_max_area}(:,1)';
        temp_polys(cnt).P(1).y = poly{idx_max_area}(:,2)';
        simple_polys{cnt} = poly{idx_max_area};
        
        configuration(idx_sensor, idx_aoa) = cnt;
        
        if debug_level > 2
            figure, cla, hold on;
            geom2d.drawPolygon(simple_polys{cnt}, 'y');
            geom2d.drawLine(temp_aoa_ray{cnt, 1}, 'color', 'g');
            geom2d.drawLine(temp_aoa_ray{cnt, 2}, 'color', 'r');
            geom2d.drawPoint(geom2d.polygonCentroid(S.sensorBoundPolygons{idx_S}));
        end
        cnt = cnt+1;
    end
end
%% calculate necessary combinations
%% combine combination sets
cnt = 1;
for idx_sensor = 1:2:num_sensors*2
    possible_configs = configuration(idx_sensor:idx_sensor+1, :);
    temp_set = possible_configs(possible_configs>0);
    if ~isempty(temp_set)
        comb_set{cnt} = temp_set;
        cnt = cnt+1;
    end
end

combinations(:, 1) = comb_set{1}';
for idx_set = 2:numel(comb_set)
    num_comb =  numel(comb_set{idx_set});
    size_combinations = size(combinations);
    combinations = repmat(combinations, num_comb, 1);
    for idx_comb = 1:num_comb
        idx_start = (idx_comb-1)*size_combinations(1)+1;
        idx_end = idx_comb*size_combinations(1);
        combinations(idx_start:idx_end, idx_set) = comb_set{idx_set}(idx_comb);
    end
end

%% calculate all polygon intersections and find combination with largest area
if debug_level > 0
    Polygons_intersection(temp_polys,1,1e-8);
end
% %%
% geo_match = [];
% geo_area = [];
%
% for idx_geo = 1:numel(Geo),
%     if numel(Geo(idx_geo).index) == size(combinations,2)
%         for idx_comb = 1:size(combinations,1)
%             if isempty(setdiff(Geo(idx_geo).index, combinations(idx_comb, :)))
%                 geo_match(end+1) = idx_geo;
%                 geo_area(end+1) = Geo(idx_geo).area;
%             end
%
%         end
%     end
% end
% idx_max_polygon = geo_match(find(geo_area==max(geo_area), 1, 'first'));
% intersect_polygon = Geo(idx_max_polygon).P;
% intersect_polygon_points = [intersect_polygon.x', intersect_polygon.y'];
% geom2d.fillPolygon(intersect_polygon_points, 'k');

%%
% figure, hold on;
ip_areas = [];
for idx_comb = 1:size(combinations, 1)
    intersect_polys{idx_comb} = simple_polys{combinations(idx_comb, 1)};
    for idx_poly = 2:size(combinations, 2)
        poly_unsorted = SimplePolygonIntersection(intersect_polys{idx_comb}, simple_polys{combinations(idx_comb, idx_poly)});
        % reorder
        if ~isempty(poly_unsorted)
            poly_centroid = geom2d.centroid(poly_unsorted);
            intersect_polys{idx_comb} = geom2d.angleSort(poly_unsorted, poly_centroid);
        else %remove combination
            intersect_polys{idx_comb} = [];
            break;
        end
    end
    if ~isempty(intersect_polys{idx_comb} )
        ip_areas(idx_comb) = geom2d.polygonArea(intersect_polys{idx_comb});
    else
        ip_areas(idx_comb) = 0;
    end
    %     geom2d.drawPolygon(intersect_polys{idx_comb});
end


idx_max_polygon = find(ip_areas==max(ip_areas), 1, 'first');
intersect_polygon_points = intersect_polys{idx_max_polygon};
% geom2d.fillPolygon(intersect_polygon_points, 'k');


%%
for idx_bounds = combinations(idx_max_polygon, :)
    [idx_S, idx_aoa] = find(configuration == idx_bounds);
    for idx_ray = 1:2
        dist_ray = geom2d.distancePointLine(intersect_polygon_points, temp_aoa_ray{idx_bounds, idx_ray});
        if min(dist_ray) > 1e-2
            %%
            
            % find relation of distance to orth. ray projection
            idx_min_dist_ray = find(dist_ray == min(dist_ray), 1, 'first');
            nearest_poly_point = intersect_polygon_points(idx_min_dist_ray, :);
            % check if distance is to great
            dist_sensor_bounds = geom2d.distancePoints(temp_aoa_ray{idx_bounds, idx_ray}(1:2), temp_aoa_ray{idx_bounds, 3-idx_ray}(1:2));
            proj_point = geom2d.projPointOnLine(nearest_poly_point, temp_aoa_ray{idx_bounds, idx_ray});
            ray_line_to_poly = geom2d.createRay(proj_point, nearest_poly_point);
            max_dist_to_go = geom2d.edgeLength([proj_point nearest_poly_point]);
            
            if max_dist_to_go < MaxDistToGo*dist_sensor_bounds
                disp(['Optimizing Sensor ' num2str(idx_S) ' by distance of ' num2str(min(dist_ray))]);
                dist_to_go = DistanceCutRatio * geom2d.edgeLength([proj_point nearest_poly_point]);
                calc_cut_point = geom2d.pointOnLine(ray_line_to_poly, dist_to_go);
                cut_ray = geom2d.parallelLine(temp_aoa_ray{idx_bounds, idx_ray}, calc_cut_point);
                
                cut_edge = [calc_cut_point; geom2d.pointOnLine(cut_ray, 1)];
                
                top_poly = cutpolygon.cutpolygon(S.sensorBoundPolygons{ceil(idx_S/2)}, cut_edge, 1, false, false);
                %             figure;
                bottom_poly = cutpolygon.cutpolygon(S.sensorBoundPolygons{ceil(idx_S/2)}, cut_edge, 2, false, false);
                %%
                if ~isempty(top_poly) && ~isempty(bottom_poly)
                    if geom2d.polygonArea(top_poly) > geom2d.polygonArea(bottom_poly)
                        new_bounds_poly = top_poly;
                    else
                        new_bounds_poly = bottom_poly;
                    end
                else
                    new_bounds_poly = S.sensorBoundPolygons{ceil(idx_S/2)};
                end
                %%
                S.sensorBoundPolygons{ceil(idx_S/2)} = new_bounds_poly;
                all_dists = geom2d.distancePoints(new_bounds_poly, temp_aoa_ray{idx_bounds, idx_ray}(1:2));
                idx_nearest_point =  find(all_dists == min(all_dists),1,'first');
                new_bound_angle = geom2d.angle2Points(new_bounds_poly(idx_nearest_point,:), nearest_poly_point) - it_aoas{idx_S}(idx_aoa);
                new_bound_angle = geom2d.normalizeAngle(new_bound_angle, 0);
                %%
                if debug_level > 1
                    figure;
                    cla;
                    hold on;
                    geom2d.drawPolygon(new_bounds_poly);
                    geom2d.drawPolygon(intersect_polygon_points);
                    geom2d.drawPoint(proj_point);
                    geom2d.drawPoint(calc_cut_point, 'color','m');
                    geom2d.drawLine(cut_ray, 'color', 'm');
                    geom2d.drawPoint(temp_aoa_ray{idx_bounds, idx_ray}(1:2),'color', 'k');
                    geom2d.drawLine(temp_aoa_ray{idx_bounds, idx_ray},'color', 'k');
                    geom2d.drawPoint(temp_aoa_ray{idx_bounds, 3-idx_ray}(1:2),'color', 'y');
                    geom2d.drawLine(temp_aoa_ray{idx_bounds, 3-idx_ray},'color', 'y');
                    geom2d.drawPoint([new_bounds_poly(idx_nearest_point,:); nearest_poly_point],'color', 'g');
                    geom2d.drawLine(geom2d.createRay(new_bounds_poly(idx_nearest_point,:), new_bound_angle), 'color','g');
                end
                %%
                disp(['Angle Nr.:' num2str(idx_ray) ' with Value ' num2str(geom2d.rad2deg(S.sensorAoaBounds{idx_S}(idx_ray))) ' is corrected to ' num2str(geom2d.rad2deg(new_bound_angle))]);
                geom2d.drawLine(geom2d.createRay(new_bounds_poly(idx_nearest_point,:), S.sensorAoaBounds{idx_S}(idx_ray)), 'color', 'r');
                S.sensorAoaBounds{idx_S}(idx_ray)  = new_bound_angle;
                
                %                 aoa_cleared_angle = geom2d.lineAngle(cut_ray) - it_aoas{idx_S}(idx_aoa);
                %                 if abs(geom2d.normalizeAngle(aoa_cleared_angle - S.sensorAoaBounds{idx_S}(1), 0)) < abs(geom2d.normalizeAngle(aoa_cleared_angle - S.sensorAoaBounds{idx_S}(2), 0))
                %                     disp(['Angle ' num2str(geom2d.rad2deg(S.sensorAoaBounds{idx_S}(1))) ' is corrected to ' num2str(geom2d.rad2deg(new_bound_angle))]);
                %                     geom2d.drawLine(geom2d.createRay(new_bounds_poly(idx_nearest_point,:), S.sensorAoaBounds{idx_S}(1)), 'color', 'r');
                %                     S.sensorAoaBounds{idx_S}(1)  = new_bound_angle;
                %                 else
                %                     disp(['Angle ' num2str(geom2d.rad2deg(S.sensorAoaBounds{idx_S}(2))) ' is corrected to ' num2str(geom2d.rad2deg(new_bound_angle))]);
                %                     geom2d.drawLine(geom2d.createRay(new_bounds_poly(idx_nearest_point,:), S.sensorAoaBounds{idx_S}(2)), 'color','r');
                %                     S.sensorAoaBounds{idx_S}(2)  = new_bound_angle;
                %                 end
                %             Experimental.plotIterativeSensorState(S);
            end
        end
    end
end
%figure;


end


