function pc = positions(pc)

% check prerequisites
if ~pc.progress.environment.load
    pc = environment.load(pc);
end

if pc.sensorspace.angles_sampling_occurence == pc.sensorspace.angles_sampling_occurences.pre
    %%
      pc.sensorspace.angles = sensorspace.angles(pc);
end

switch pc.sensorspace.position_sampling_technique
    case pc.common.sampling_techniques.random
        error('not yet converted to new format');
%         pc = generate_random_sensorspace_positions(pc);
    case pc.common.sampling_techniques.uniform
        %%
        pc = sensorspace.uniform_positions(pc);
    otherwise
        error('not implemented');
end
%% remove positions that are outside of workspace
% in_workspace = binpolygon(int64(pc.problem.S(1:2, :)), pc.environment.walls.ring, pc.common.grid_limit);
% write_log('Removed %d of %d sensor positions that are not in or on workspace', sum(~in_workspace) ,numel(in_workspace));
% % mb.drawPoint(pc.problem.S(:, ~in_workspace),'og');
% pc.problem.S = pc.problem.S(:, in_workspace);

%% verbose
%h_pts = mb.drawPoint(pc.problem.S(1:2, :));
% h_pts = mb.drawPoint(pc.problem.S(1:2, ~in_workspace));
% delete(h_pts)


%% remove positions that are 'on' obstacles
if ~isempty(pc.environment.obstacles.poly)
in_obstacle = binpolygon(int64(pc.problem.S(1:2,:)), pc.environment.obstacles.poly);
write_log('Removed %d of %d sensor positions in obstacles', sum(in_obstacle), numel(in_obstacle));
% mb.drawPoint(pc.problem.S(:, in_obstacle),'ob');
pc.problem.S = pc.problem.S(:, ~in_obstacle);
end

%% verbose
%h_pts = mb.drawPoint(pc.problem.S(1:2, :));
% h_pts = mb.drawPoint(pc.problem.S(1:2, in_obstacle));
% delete(h_pts)

%% remove dublicate positions and positions within snap distance if they exist and sort positions by x, y, phi
[S_unique, ~, u_p_ic] = unique(pc.problem.S', 'rows', 'sorted');
%%% remove positions within snap distance
[unique_positions, ~, u_p_ic] = unique(S_unique(:,1:2), 'rows', 'stable');
S_flt_dist = sqrt(sum(diff([-inf(1,2);unique_positions], 1, 1).^2, 2))<=pc.common.snap_distance;
s1 = find(S_flt_dist)-1;
s2 = find(S_flt_dist);
% dall = distancePoints(unique_positions, unique_positions);
% id_merge = find(triu(dall,1) > 0 & triu(dall,1) <= pc.common.snap_distance);
% [s1, s2] = ind2sub(size(dall), id_merge);
%%%
for ids = 1:numel(s1)
    ids_s1 = find(u_p_ic==s1(ids));
    ids_s2 = find(u_p_ic==s2(ids));
    pos_merge = round((S_unique(ids_s1(1), 1:2)+S_unique(ids_s2(1), 1:2))/2);
    S_unique([ids_s1; ids_s2],1) = pos_merge(1);
    S_unique([ids_s1; ids_s2],2) = pos_merge(2);
end
write_log('Removed %d sensor positions within snap distance', numel(s1));
%%
pc.problem.S = unique(S_unique, 'rows', 'sorted')';
write_log('Removed %d dublicated sensor positions', size(S_unique, 1)-size(pc.problem.S, 2));

%% remove positions with an angular distance that is too close
S_flt_dist = abs(sum(diff([-inf(3,1) ,pc.problem.S], 1, 2), 1))<=pc.sensorspace.min_angle_distance;
write_log('Removed %d of %d sensor positions with too close angular distances', sum(S_flt_dist), numel(S_flt_dist));
pc.problem.S = pc.problem.S(:, ~S_flt_dist);

%% verbose
%h_pts = mb.drawPoint(pc.problem.S(1:2, :));
%h_pts = mb.drawPoint(pc.problem.S(1:2, S_flt_dist));
% delete(h_pts)



%%
pc.sensorspace.number_of_angles_per_position = numel(pc.sensorspace.angles);
pc.problem.num_sensors = size(pc.problem.S, 2);
% pc.problem.num_sensors = pc.problem.num_sensors;
pc.problem.t_sum = numel(pc.sensors);
pc.problem.num_sensorpositions = size(unique(pc.problem.S(1:2,:)', 'rows'),1);
pc.problem.St_i = zeros(pc.problem.num_sensors, pc.problem.t_sum);

% prerequisite fullfiled
pc.progress.sensorspace.positions = true;