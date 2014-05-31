function pc = quality_constraints(pc)
%% quality constraints are buid as follows:
% for each workspace point all possible sensor combinations are calculated
% and valued, therefore the sameplace constraints must be calculated first
%
% for each possible sensorcombination, a boolean value di1i2 is created
% that holds the result of the boolean equation S1&S2
%
% Now for every workspace point a quality variable is created that is a min
% over all sensor combination from which it is seen. It is calculated as
% qd12w1(0.1) <= qd23w1(0.3) <= qd34w1(0.5)
%
%  d12       d23         d34     qw1
%  0.1       0            0      -1
%  -1        0.3          0      -1
%  -1        -1           0.5    -1
%% create index matrix for all sensor combinations SC
% profile on;
% clearvars -except pc
% use straight forward sum(n-1:n-i1)-(n-i2) to calculate intersection index
num_sensors = pc.problem.num_sensors;
num_positions = pc.workspace.number_of_positions;
% num_combinations = num_sensors*(num_sensors-1)/2;

% for each workspace point, the quality matrix holds:
% {row_id} = si1, si2, Qi1i2j
quality_matrix_1_sin = cell(num_positions, 1);

% function that calculates sa from the sensor indices si1 si2
% fun_sensor_comb_idx = @(si1, si2) sum(num_sensors-si1:num_sensors-1)-(num_sensors-si2);
pc.problem.W = double(pc.problem.W);
% eps = 0.1;
% idwp = 1;

%%%
tic
pct = 0;
write_log('calculating all qualities for every workspace point');
for idwp = 1:num_positions
    %%
    sensor_ids = find(pc.problem.xt_ij(:, idwp));
    sensor_unique_combinations = comb2unique(sensor_ids);
    
    if ~isempty(pc.model.sameplace.A)
    %%%
    % find illegal combinations and remove them
    % basic idea is to find the column indices which are the sensor ids
    % then create the combinations that arise in the constraint rows and
    % remove them from the unique combinations
    constraint_mat = pc.model.sameplace.A(:, sensor_ids);
    % clean rows with zero or one sensor in it
    constraint_mat = constraint_mat(sum(constraint_mat, 2)>1, :);
    %%
    constraints_sensor_ids = arrayfun(@(row_id) find(constraint_mat(row_id, :)), 1:size(constraint_mat,1), 'uniformoutput', false);
    constraints_sensor_combs = cell2mat(cellfun(@(ids) comb2unique(ids'), constraints_sensor_ids, 'uniformoutput', false)');  
    
    sensor_relevant_combinations = setdiff(sensor_unique_combinations, constraints_sensor_combs, 'rows');   
    else
        warning('sameplace constraints not used');
        sensor_relevant_combinations = sensor_unique_combinations;
    end
%%
%     distS1Pt  = mb.distancePoints(pc.problem.W(1:2,idwp), pc.problem.S(1:2, sensor_relevant_combinations(:,1)));
%     distS2Pt  = mb.distancePoints(pc.problem.W(1:2,idwp), pc.problem.S(1:2, sensor_relevant_combinations(:,2)));
%     qa_dist = ((distS1Pt+distS2Pt-pc.sensors.distance.min)/(2*(pc.sensors.distance.max-pc.sensors.distance.min)));
    qa_1_sin = sin(mb.angle3PointsFast(pc.problem.S(1:2, sensor_relevant_combinations(:,1)), pc.problem.W(1:2,idwp), pc.problem.S(1:2, sensor_relevant_combinations(:,2))));
%%
    [qa_1_sin_sorted, qa_1_sin_ids] = sort(qa_1_sin);
    sensor_2comb_diffids_sorted = sensor_relevant_combinations(qa_1_sin_ids,:);
    % only consider qualities > 0
    flt_quality = qa_1_sin_sorted >= pc.workspace.quality.min;
    quality_matrix_1_sin{idwp} = [sensor_2comb_diffids_sorted(flt_quality,:), qa_1_sin_sorted(flt_quality)'];
    
    if pct < floor(idwp*10/num_positions)
        pct = floor(idwp*10/num_positions);
        rest_time = toc/pct*(10-pct);
        write_log('%d pct %g sec to go\n', pct*10, rest_time);
    end
end
write_log('calculated in %g sec\n', toc);
clearvars qa*

%% calculate all necessary sensor combinations and negations
all_combinations_and_qualities = cell2mat(quality_matrix_1_sin);
all_combinations_indices = [0; cumsum(cellfun(@(mat) size(mat,1), quality_matrix_1_sin))];
clearvars quality_matrix_1_sin
[unique_combinations, ~, unique_indices] = unique(sort(all_combinations_and_qualities(:,1:2), 2), 'rows');
num_unique_combinations = size(unique_combinations, 1);

%% create equations
% -si1 - si2 + di1i2 >= -1
% matrix representations has the form 
% lhs_comb_gt <=           A_comb_gt       <= rhs_comb_gt 
%                 Si1 ... Si2 .... di1i2
%  -inf        <= [ 1      1        -1   ] <= 1
% obj_comb = zeros(1,num_unique_combinations);
row_ids_comb_gt = repmat(1:num_unique_combinations, 1, 3);
num_columns_A_combs = num_unique_combinations+pc.problem.num_sensors;
column_ids_comb_gt = [unique_combinations (num_sensors+1:num_columns_A_combs)'];
values_comb_gt = [ones(size(unique_combinations)), -ones(size(unique_combinations,1),1)];
A_comb_gt = sparse(row_ids_comb_gt(:), column_ids_comb_gt(:), values_comb_gt(:), num_unique_combinations, num_columns_A_combs);
rhs_comb_gt = ones(size(A_comb_gt,1),1);
lhs_comb_gt = -inf(size(A_comb_gt,1),1);

%% -si1 + di1i2 <= 0
% -si2 + di1i2 <= 0
% two values per row and two equations
% lhs_comb_gt >=           A_comb_gt       <= rhs_comb_gt 
%                 Si1 ... Si2 .... di1i2
%  -inf       <= [ -1               1   ] <= 0
%  -inf       <= [        -1        1   ] <= 0

row_ids_comb_lt = repmat(1:2*num_unique_combinations, 1, 2);
column_ids_comb_lt = [unique_combinations, repmat((pc.problem.num_sensors+1:num_columns_A_combs)', 1, 2)];
values_comb_lt = [-1*ones(2*num_unique_combinations, 1), ones(2*num_unique_combinations, 1)]; 
A_comb_lt = sparse(row_ids_comb_lt(:), column_ids_comb_lt(:), values_comb_lt(:), 2*num_unique_combinations, num_columns_A_combs);
lhs_comb_lt = -inf(size(A_comb_lt, 1),1);
rhs_comb_lt = zeros(size(A_comb_lt, 1),1);

% combine matrices
A_comb = [A_comb_gt; A_comb_lt];
num_rows_A_comb = size(A_comb, 1);
rhs_comb = [rhs_comb_gt; rhs_comb_lt];
lhs_comb = [lhs_comb_gt; lhs_comb_lt];

pc.model.sensor_combinations.A = A_comb;
pc.model.sensor_combinations.num_columns = num_columns_A_combs;
pc.model.sensor_combinations.num_rows = num_rows_A_comb;
pc.model.sensor_combinations.ctype = repmat('B', 1, num_columns_A_combs-num_sensors);
pc.model.sensor_combinations.obj = zeros(num_columns_A_combs-num_sensors, 1);
pc.model.sensor_combinations.rhs = rhs_comb;
pc.model.sensor_combinations.lhs = lhs_comb; 
pc.model.sensor_combinations.lb = zeros(num_columns_A_combs-num_sensors,1);
pc.model.sensor_combinations.ub = ones(num_columns_A_combs-num_sensors,1);
%%
clearvars *_lt *_gt

% profile viewer;
%%% Now for every workspace point a quality variable is created that is the sum of all quality values
% therefore the min quality is 0 which is the same as if the sensor combination does not see the 
% workspace point
%       d12       d23         d34     qw1
% 0 <=  .1         .2          .3      -1 <= inf

% qw1_obj = -1

%%
% num_quality_colums = all_combinations_indices(end);
num_A_quality_rows  = num_positions;
num_A_quality_colums = num_columns_A_combs+num_positions;
A_quality = zeros(num_A_quality_rows, num_A_quality_colums);
% quality_row_ids = zeros(num_quality_colums, 1);
% quality_colum_ids_row = zeros(num_quality_colums, 1);
% quality_colum_ids_qwx = zeros(num_quality_constraints, 1);
% quality_values_row = zeros(num_quality_constraints, 1);
% quality_values_qwx = zeros(num_quality_constraints, 1);
quality_values_qwx = diag(-ones(num_A_quality_rows,1));
quality_row_ids_qwx = (1:num_A_quality_rows)';
quality_column_ids_qwx = num_columns_A_combs+(1:num_A_quality_rows)';
A_quality(quality_row_ids_qwx, quality_column_ids_qwx) = quality_values_qwx;
%%
% row_idx = 0;
pct = 0;
tic;
write_log('calculating min quality function');
for idwp = 1:num_positions
    %%
    wp_indices = (all_combinations_indices(idwp)+1:all_combinations_indices(idwp+1));
    sensorcomb_const_ids = num_sensors+unique_indices(wp_indices);
%     num_constraints = numel(sensorcomb_const_ids);
%    A_quality(idwp, num_sensors+1:end) = -1e-6;
    A_quality(idwp, sensorcomb_const_ids(:)) = all_combinations_and_qualities(wp_indices,3);%./num_constraints;
    
    
%     num_constraints = numel(sensorcomb_const_ids);
    % create diag with quality values
    % q_diag_column_id is sensorcomb_const_ids
%     quality_colum_ids_row(wp_indices) = sensorcomb_const_ids;
%     quality_colum_ids_qwx(idwp) = num_columns_A_combs+idwp;    
%     quality_row_ids(wp_indices) = idwp*ones(num_constraints,1);
%     quality_values_row(wp_indices) = all_combinations_and_qualities(wp_indices,3);
%     quality_values_qwx(idwp) = -ones(num_constraints, 1);
    
    if pct < floor(idwp*10/num_positions)
        pct = floor(idwp*10/num_positions);
        rest_time = toc/pct*(10-pct);
        write_log('%d pct %g sec to go\n', pct*10, rest_time);
    end   
end
write_log('calculated in %g sec\n', toc);

%%
% A_quality = sparse([quality_row_ids; quality_row_ids_qwx], [quality_colum_ids_row; quality_column_ids_qwx], [quality_values_row; quality_values_qwx], num_quality_constraints, num_columns_A_combs+num_positions);
rhs_quality = inf(num_A_quality_rows, 1);
lhs_quality = zeros(num_A_quality_rows, 1);
%%
pc.model.quality.directional.all_combinations_and_qualities = all_combinations_and_qualities;
pc.model.quality.directional.num_columns = num_columns_A_combs+num_positions;
pc.model.quality.directional.num_rows = num_A_quality_rows;
pc.model.quality.directional.ctype = [repmat('B', 1, num_columns_A_combs-num_sensors), repmat('C', 1, num_positions)];
pc.model.quality.directional.obj = [zeros(num_columns_A_combs-num_sensors, 1); -ones(num_positions,1)];
pc.model.quality.directional.A = [A_comb, sparse(num_rows_A_comb, num_positions); sparse(A_quality)];
pc.model.quality.directional.A_quality = A_quality;
pc.model.quality.directional.rhs = [rhs_comb; rhs_quality];
pc.model.quality.directional.lhs = [lhs_comb; lhs_quality];
pc.model.quality.directional.lb = [zeros(num_columns_A_combs-num_sensors,1); zeros(num_positions,1)];
pc.model.quality.directional.ub = [ones(num_columns_A_combs-num_sensors,1); ones(num_positions,1)];
clearvars quality_*








% %% OBSOLETE QUALITY CALCULATION
% % profile viewer;
% %%% Now for every workspace point a quality variable is created that is a min
% % over all sensor combination from which it is seen. It is calculated as
% % qd12w1(0.1) <= qd23w1(0.3) <= qd34w1(0.5)
% %
% %  d12       d23         d34     qw1
% %  0.1       0            0      -1
% %  -1        0.3          0      -1
% %  -1        -1           0.5    -1
% %
% % due to the great number of variables which are needed for this the
% % constraint is reformed to calculate the negative maximum
% %       d12       d23         d34     qw1
% % 0 <= -1+0.1      0           0       -1 <= inf
% % 0 <=   0       -1+0.3        0       -1 <= inf
% % 0 <=   0         0         -1+0.5    -1 <= inf

% %%
% num_quality_const = all_combinations_indices(end);
% quality_row_ids = zeros(num_quality_const, 1);
% quality_colum_ids_diag = zeros(num_quality_const, 1);
% quality_colum_ids_qwx = zeros(num_quality_const, 1);
% quality_values_diag = zeros(num_quality_const, 1);
% quality_values_qwx = zeros(num_quality_const, 1);
% %%
% row_idx = 0;
% pct = 0;
% tic;
% write_log('calculating min quality function');
% for idwp = 1:num_positions
    % %%
% %     sensorcomb_qualities_wp = quality_matrix_1_sin{idwp};
% %     [~, sensorcomb_const_ids] = intersect(unique_combinations, quality_matrix_1_sin{idwp}(:,1:2), 'rows');
% %     sensorcomb_const_ids = unique_combinations(:,1)==quality_matrix_1_sin{idwp}(:,1)&unique_combinations(:,2)==quality_matrix_1_sin{idwp}(:,2);
    % wp_indices = all_combinations_indices(idwp)+1:all_combinations_indices(idwp+1);
    % sensorcomb_const_ids = unique_indices(wp_indices);
    % num_constraints = numel(sensorcomb_const_ids);
    % % create diag with quality values
    % % q_diag_column_id is sensorcomb_const_ids
    % quality_colum_ids_diag(wp_indices) = sensorcomb_const_ids;
    % quality_colum_ids_qwx(wp_indices) = repmat(num_columns_A_combs+idwp, num_constraints, 1);
    
    % quality_row_ids(wp_indices) = row_idx+(1:num_constraints)';
    % row_idx = row_idx+num_constraints;

    % quality_values_diag(wp_indices) = -1 + all_combinations_and_qualities(wp_indices,3);
    % quality_values_qwx(wp_indices) = -ones(num_constraints, 1);
    
    % if pct < floor(idwp*10/num_positions)
        % pct = floor(idwp*10/num_positions);
        % rest_time = toc/pct*(10-pct);
        % write_log('%d pct %g sec to go\n', pct*10, rest_time);
    % end   
% end
% write_log('calculated in %g sec\n', toc);

% %%
% A_quality = sparse([quality_row_ids; quality_row_ids], [quality_colum_ids_diag; quality_colum_ids_qwx], [quality_values_diag; quality_values_qwx], num_quality_const, num_columns_A_combs+num_positions);
% rhs_quality = sparse(num_quality_const, 1);
% lhs_quality = -inf(num_quality_const, 1);
% %%
% pc.model.quality.directional.all_combinations_and_qualities = all_combinations_and_qualities;
% pc.model.quality.directional.num_columns = num_columns_A_combs+num_positions;
% pc.model.quality.directional.num_rows = num_quality_const;
% pc.model.quality.directional.ctype = [repmat('B', 1, num_columns_A_combs-num_sensors), repmat('C', 1, num_positions)];
% pc.model.quality.directional.obj = [zeros(num_columns_A_combs-num_sensors, 1); ones(num_positions,1)];
% pc.model.quality.directional.A = [A_comb, sparse(num_rows_A_comb, num_positions); A_quality];
% pc.model.quality.directional.rhs = [rhs_comb; rhs_quality];
% pc.model.quality.directional.lhs = [lhs_comb; lhs_quality];
% pc.model.quality.directional.lb = [zeros(num_columns_A_combs-num_sensors,1); -inf(num_positions,1)];
% pc.model.quality.directional.ub = [ones(num_columns_A_combs-num_sensors,1); zeros(num_positions,1)];
% clearvars quality_*



