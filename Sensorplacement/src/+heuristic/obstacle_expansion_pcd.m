function pc = heuristic_placement_obstacle_expansion_pcd(pc)
% calculates a heuristic k placement in the given convex rings. If the
% max ring diameter is less then the max sensing distance, the placement is
% done by minimizing the placed sensors according to the polygon angles.
% If the diameter is greater then the sensing distance, then a greedy
% approach is taken and it is tried to maximize the covered area.
% all parameters are passed in the pc structure

%% calculate convex decomposition



%% dispatch the rings to the appropriate heuristic
sensor.polyline_verticies = pc.common.polyline_verticies;
choosen_poses = cell(1,numel(rings));
splitted_rings = cell(1,numel(rings));
for idr = 1:numel(rings)
%     ring_geom = mb.boost2visilibity(rings{idr});
    max_distance = max(polygonInterpointDistances(rings{idr}));
    if max_distance > sensor.distance
        if nargin < 3 || isempty(cutting_edges)
            % we can cut everywhere
            cutinfo = false(size(rings,2), 1);
        else 
            cutinfo = cutting_edges{idr};
        end        
        [choosen_poses{idr}, splitted_rings{idr}] = calculate_placement_in_big_convex(rings{idr}, sensor, k, cutinfo, max_distance);
    else
        choosen_poses{idr} = calculate_placement_in_small_convex(rings{idr}, sensor, k);
        splitted_rings{idr} = rings{idr};
    end
end

end

function [choosen_poses] = calculate_placement_in_small_convex(ring, sensor, k, steiner_points, verbose)
%% calculates the poses for k coverage(max number of edges in convex polys)
% the algorithm sorts the edges of each convex piece according to their
% angle and calculates the number and pose of each sensor to place.
% Steiner points can occur in the PCD and have to be excuded from placement
% Returns: choosen_points {[3, numel(pcd)], ... },
%   whereas choosen_points{1} hold the placement in the smallest angle...
% angles_mountable = ~(steiner_points & circshift(steiner_points, [0 1]));
if nargin < 3 || isempty(steiner_points)
    steiner_points = false(1,size(ring,2));
end

pts_mountable = double(ring(:,~steiner_points));
pcd_angles = cell2mat(mb.polygonAngles(ring(:, steiner_points)));
pcd_polyline_angles = cell2mat(mb.polylineAngles(ring));
[angles_sorted, idx_angles] = sort(pcd_angles);



% points_sorted = points(:, idx_angles);
% calculates the positions and angles of sensor poses for the polygon edges
% the line angle is the starting angle for each edge, the edge_angle is the
% edge opening
%%
fun_placed_points = @(line_angle, edge_angle, px,py) [repmat([px;py], 1, ceil(edge_angle/sensor.angle));...
    line_angle+(sensor.angle*(0:ceil(edge_angle/sensor.angle)-1))];
placed_poses = arrayfun(fun_placed_points,pcd_polyline_angles(idx_angles),angles_sorted, pts_mountable(1,idx_angles)', pts_mountable(2,idx_angles)', 'uniformoutput', false);
choosen_poses = cell2mat(placed_poses(1:k)');
%%
if nargin > 4 && verbose
    %%
    cla, hold on;
    mb.drawPolygon(ring);
    drawPose(choosen_poses);
        
end

end

function [choosen_poses, new_rings] = calculate_placement_in_big_convex(bring, sensor, k, cutinfo, max_dist)
%% calculates the poses for k coverage in big convex rings by splitting the ring at
% non cutting edges. For this we use a small linear optimization that tries
% to find the cutting edge that decreases the polygon expand for both new
% polygons
choosen_poses = cell(1,2);
new_rings = cell(1,2);
is_placed = false;
while ~is_placed
    cutted_rings = polygonCentroidSplitting(bring, cutinfo);
    max_distances = cellfun(@(poly) max(polygonInterpointDistances(poly)), cutted_rings);
    if any(max_distances > sensor.distance)
        if any(max_distances >= max_dist)
            error('splitting does not lead to smaller interpoint distances');
        end
    end
    for idb = 1:2;
        if (max_distances > sensor.distance)
            [choosen_poses{idb}, new_rings{idb}] =  calculate_placement_in_big_convex(cutted_rings{idb}, sensor, k, cutinfo, max_distance);
        else
            [choosen_poses{idb}, new_rings{idb}] =  calculate_placement_in_small_convex(cutted_rings{idb}, sensor, k, cutinfo);
        end
    end
end


end
% 
% function new_rings = split_ring(ring, cutinfo)
%     %% function that splits big ring by optimizing edge lengths
%     ring_dbl = double(ring);
%     valid_edges = find(cutinfo);
%     valid_combinations = comb2unique(valid_edges);
% 
%     for idvc = 1:size(valid_combinations, 1)
%         %%
%         line1 = createLine(ring_dbl(:, valid_combinations(idvc, 1))', ring_dbl(:,valid_combinations(idvc, 1)+1)');
%         line2 = createLine(ring_dbl(:,valid_combinations(idvc, 2))', ring_dbl(:,valid_combinations(idvc, 2)+1)');
%         
%         fminsearch(
%     end
%     
%     
% end

function sum_distance = poly_interpoint_distances(bpoly)
    ring_geom = mb.boost2visilibity(bpoly);
       pointcomb = comb2unique(1:size(ring_geom,1));
    point_distance = distancePoints(ring_geom(pointcomb(:,1), :), ring_geom(pointcomb(:,2), :), 'diag');
end

% function [choosen_poses] = calculate_placement_in_big_convex(ring, sensor, k)
% %% calculates the poses for k coverage in big convex rings by using a
% % greedy heuristic. The placement positions are calculated by covered area
% % calculate covering area
%
% pcd_angles = cell2mat(mb.polygonAngles(ring));
% is_placed = false(numel(pcd_angles), 1);
%
%
% fun_sensorfov = @(x,y,phi) int64([[x;y], circleArcToPolyline([[x y], sensor.distance, rad2deg(phi), sensor.fov], sensor.polyline_verticies)', [x;y]]);
% sensor_cones = arrayfun(ring(1,:), ring(2,:), pcd_angles, 'uniformoutput', false);
% polys = [ring, sensor_cones{:}];
% jobs = [ones(numel(sensor_cones), 1), 1+(1:numel(sensor_cones))'];
% [sensor_cones_and_ring, sensor_cones_and_ring_areas] = bpolyclip_batch(polys, 1, jobs, true);




