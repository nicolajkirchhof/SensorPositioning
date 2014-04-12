function pc = dirdist(pc)
% Loops through all relevant combinations and calculates the qualities for every workspace
% point. 

quality_type = pc.quality.types.wss_dirdist;
if ~pc.progress.sensorspace.sensorcomb
    pc = sensorspace.sensorcomb(pc);
end

write_log('calculating directional quality values');
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
wp_q_d1d2sin = cell(pc.problem.num_positions, 1);
for idw = 1:pc.problem.num_positions
    %%
    idc = pc.problem.wp_sc_idx(:, idw);
    s1_idx = pc.problem.sc_idx(logical(idc),1);
    s2_idx = pc.problem.sc_idx(logical(idc),2);
    %%
    q_sin = single(sin(mb.angle3PointsFast(pc.problem.S(1:2, s1_idx), pc.problem.W(:,idw), pc.problem.S(1:2, s2_idx))))';    
    ds1 = mb.distancePoints(pc.problem.W(:,idw), pc.problem.S(1:2, s1_idx));
    ds2 = mb.distancePoints(pc.problem.W(:,idw), pc.problem.S(1:2, s2_idx));
    dqg = sqrt(ds1.*ds2)./(pc.sensors.distance.max);
    dqm = (ds1+ds2)./(2*pc.sensors.distance.max);
    cla, plot(dqg), plot(dqm, 'r'), hold on;
    %%
    below_qdmax = dq<=pc.sensors.quality.distance.max;
    above_dmax = dq>pc.sensors.quality.distance.max;
    %%%
    dq(below_qdmax) = pc.sensors.quality.distance.scale*(dq(below_qdmax)./pc.sensors.quality.distance.max);
    dq(above_dmax) = pc.sensors.quality.distance.scale*((1-dq(above_dmax))./(1-pc.sensors.quality.distance.max));
    %%
    plot(dq, 'g');
    plot(dq(below_qdmax), 'r');
    %%
    wp_q_d1d2sin{idw} = q_sin.*dq';
    loop_display(idw);
end
%%
write_log('calculation finished');
% qa_row_ids = cell2mat(pc.problem.sc_wp_idx(sub2ind(size(pc.problem.sc_wp_idx), pc.problem.sc_idx(:,1), pc.problem.sc_idx(:,2))));
% qa_1_sin = cell2mat(qa_1_sin')';
% pc.problem.q_sin = q_sin(pc.problem.sc_ind);
% pc.problem.wp_q_d1d2sin = wp_q_d1d2sin;
pc.quality.(quality_type).val = wp_q_d1d2sin;
pc.progress.quality.(quality_type) = true;
