function pc = distance(pc)
% Loops through all workspace points and calculates the distance to all sensors

if ~pc.progress.sensorspace.sensorcomb
    pc = sensorspace.sensorcomb(pc);
end

write_log('calculating distance quality values');
% num_comb = size(pc.problem.sc_idx, 1);
% q_sin = cell(pc.problem.num_sensors);
% calculate quality for every workspace point in every sensor combination
loop_display(pc.problem.num_positions, 10);
% for idc = 1:num_comb
    %%
%     s1_idx = pc.problem.sc_idx(idc,1);
%     s2_idx = pc.problem.sc_idx(idc,2);
%     w_idx = pc.problem.sc_wp_idx{idc};
%     q_sin{s1_idx, s2_idx} = single(sin(mb.angle3PointsFast(pc.problem.S(1:2, s1_idx), pc.problem.W(1:2,w_idx), pc.problem.S(1:2, s2_idx))))';
% end
wp_q_dist = zeros(pc.problem.num_positions, pc.problem.num_sensors);
for idw = 1:pc.problem.num_positions
    sensor_flt = pc.problem.xt_ij(:,idw);
    distances = mb.distancePoints(pc.problem.W(:,idw), pc.problem.S(1:2, sensor_flt));
    wp_q_dist(idw, sensor_flt) = distances;
    wp_q_dist(idw, ~sensor_flt) = inf;
end
pc.problem.wp_q_dist = wp_q_dist;
%%
write_log('calculation finished');
% qa_row_ids = cell2mat(pc.problem.sc_wp_idx(sub2ind(size(pc.problem.sc_wp_idx), pc.problem.sc_idx(:,1), pc.problem.sc_idx(:,2))));
% qa_1_sin = cell2mat(qa_1_sin')';
% pc.problem.q_sin = q_sin(pc.problem.sc_ind);

pc.progress.sensorspace.quality.distance = true;
