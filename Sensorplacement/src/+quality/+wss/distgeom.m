function pc = distgeom(pc)
% Loops through all relevant combinations and calculates the qualities for every workspace
% point. 
[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
quality_type = [model_prefix '_' model_name];
%%
if ~pc.progress.sensorspace.sensorcomb
    pc = sensorspace.sensorcomb(pc);
end
%%
write_log('calculating directional geometric meand quality values');
% num_comb = size(pc.problem.sc_idx, 1);
% q_sin = cell(pc.problem.num_sensors);
% calculate quality for every workspace point in every sensor combination
wp_q_d1d2sin = cell(pc.problem.num_positions, 1);
loop_display(pc.problem.num_positions, 10);

for idw = 1:pc.problem.num_positions
    %%
    idc = pc.problem.wp_sc_idx(:, idw);
    s1_idx = pc.problem.sc_idx(logical(idc),1);
    s2_idx = pc.problem.sc_idx(logical(idc),2);
    %%
    ds1 = mb.distancePoints(pc.problem.W(:,idw), pc.problem.S(1:2, s1_idx));
    ds2 = mb.distancePoints(pc.problem.W(:,idw), pc.problem.S(1:2, s2_idx));
    dq = sqrt(ds1.*ds2)./(pc.sensors.distance.max);
    
    %%
%     below_qdmax = dq<=pc.sensors.quality.distance.max;
%     above_dmax = dq>pc.sensors.quality.distance.max;
%     %%%
%     dq(below_qdmax) = pc.sensors.quality.distance.scale*(dq(below_qdmax)./pc.sensors.quality.distance.max);
%     dq(above_dmax) = pc.sensors.quality.distance.scale*((1-dq(above_dmax))./(1-pc.sensors.quality.distance.max));
%     %%
%     plot(dq, 'g');
%     plot(dq(below_qdmax), 'r');
%     %%
    wp_q_d1d2sin{idw} = dq';
    if mod(idw, pc.problem.num_positions/100) < 1
    loop_display(idw);
    end
end
if pc.common.debug; cla,hold on;
    pause
    for idw = 1:pc.problem.num_positions
        dq = wp_q_d1d2sin{idw};
        plot3(ones(size(dq))*idw, 1:numel(dq), dq);
    end
        theme(gca, 'office', false);
end
%%
write_log('calculation finished');
% qa_row_ids = cell2mat(pc.problem.sc_wp_idx(sub2ind(size(pc.problem.sc_wp_idx), pc.problem.sc_idx(:,1), pc.problem.sc_idx(:,2))));
% qa_1_sin = cell2mat(qa_1_sin')';
% pc.problem.q_sin = q_sin(pc.problem.sc_ind);
% pc.problem.wp_q_d1d2sin = wp_q_d1d2sin;
pc.quality.(quality_type).val = wp_q_d1d2sin;
pc.progress.quality.(quality_type) = true;
