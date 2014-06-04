function pc = distance_constraints(pc)
%% distance constraints are buid as follows:
% iterate over all points and calculate the distance to all visible sensors
% the distance is then normed to match the sensor range, whreas 
% 0 is a bad quality and has the max or min distance to the sensor 
% 1 is the best quality and is exactly max/2

% There are two possibilities to formulate the optmization from the distance values

A = zeros(pc.problem.num_positions, pc.problem.num_sensors);
tic
% pct = 0;
write_log('calculating all distances for every workspace point');
for idwp = 1:pc.problem.num_positions
    sensor_flt = pc.problem.xt_ij(:,idwp);
    distances = mb.distancePoints(pc.problem.W(:,idwp), pc.problem.S(1:2, sensor_flt));
    normed_distances = abs((distances/pc.sensors.distance.max)-1);
    %% debug
%     figure, plot(normed_distances), figure, plot(distances);
    A(idwp, sensor_flt) = normed_distances;
end
if pc.common.is_display
    %%
    figure, draw_workspace(pc);
    num_seen_by = sum(A, 2);
    scatter(pc.problem.W(1,:)', pc.problem.W(2,:)', 5, num_seen_by');
    colorbar;
end
%%
A(A<pc.problem.quality.distance.min) = 0;
A(A==0) = pc.common.epsilon;
pc.model.quality.distance.A = A(;
pc.model.quality.distance.rhs = [];
pc.model.quality.distance.lhs = [];
pc.model.quality.distance.ctype = [];
pc.model.quality.distance.max_point_dist = [];
pc.model.quality.directional.cutoff.lower = cutoff_struct_lower;
pc.model.quality.directional.cutoff.upper = cutoff_struct_upper;