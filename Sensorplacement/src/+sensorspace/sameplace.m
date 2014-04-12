function pc = sameplace(pc)
%% get the angles of every point and calculate the circular distance to
% have all neighbouring circular angle distances and test which overlap
% an overlap is only given if the sensor fov can be compleatly covered
% by the neighbouring sensors therefore an overlap can only occur in 
% forward direction of sorted sensor angles
% Here S1 and S3 overlap S2 
%
%             phi1+fov & phi3
%          phi2    |   phi2+fov
%              \   |   /
%                \ |  /                          
%        phi1  ____O____ phi3+fov
%

%% A_sameplace holds the constraints for each unique x,y sensor position

%%
[~, xy_unique_ia, ~] = unique(pc.problem.S(1:2,:)', 'rows', 'last');
xy_unique_diffs = diff([0; xy_unique_ia]);
% points_sorted_xy_bins = mat2cell(S', xy_unique_diffs, 3);
sp_idx = mat2cell(1:sum(xy_unique_diffs), 1, xy_unique_diffs);
% pc.problem.sp_idx = sp_idx;


%% Test Points are unique at position
% 
% num_points = numel(points_sorted_xy_bins);
% figure, hold on; colors = hsv(num_points); colors_mix = mat2cell(colors(randperm(num_points), :), ones(num_points,1), 3);
% fun_plot3d = @(x, color) plot3(x(1,:), x(2,:), x(3,:), 'marker', 'o', 'color', color );
% cellfun(fun_plot3d, points_sorted_xy_bins, colors_mix');

num_sensors = pc.problem.num_sensors;
sp_ij = zeros(num_sensors);
s_fov_rad = deg2rad(pc.sensors.fov);
%%
for idp = 1:numel(sp_idx)
    % tranform int [-pi pi] and sort
    angles = angle(exp(1i*pc.problem.S(3, sp_idx{idp})))';
    num_angles = numel(angles);
    [angles_sorted, ids_sorted] = sort(angles);
    angles_distances = arrayfun(@(idx) [inf(idx-1,1); cumsum([0; diff(angles_sorted(idx:end))])], 1:num_angles, 'uniformoutput', false);
    sensor_overlappings = cellfun(@(ang_dist) ~(ang_dist > s_fov_rad), angles_distances, 'uniformoutput', false);   
    % set last overlapping to false since otherwise a gap is created
    sensor_overlappings_mat = cell2mat(sensor_overlappings)';
    %%% reorder colums accordings to sort order 
    % since the last row is always zero, 
    % and the first one has only one sensor in it they can be neglected
    % find first occurence of last sensor in constraint
%     idx_last = find(sensor_overlappings_mat(:, end), 1, 'first');
    %%
    %%% testing results
    % figure,imagesc(angles_pairwise_abs_circdist);
    % figure, imagesc(angles_no_overlap);
    %%% Assign constraints to constraint matrix.
    
    index_range = sp_idx{idp};
    sp_ij(index_range, index_range) = sensor_overlappings_mat;
%     sp_ij_cell{end+1} = false(idx_last, num_sensors);
%     sp_ij_cell{end}(:, index_range) = sensor_overlappings_mat(1:idx_last,ids_sorted);
end
%%
pc.problem.sp_ij = sp_ij;
pc.progress.sensorspace.sameplace = true;
