function pc = distance(pc, opt_dist)
% Loops through all workspace points and calculates the distance to all sensors

[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
quality_type = [model_prefix '_' model_name];

if nargin < 2
    opt_dist = 0;
    warning('%s no opt_dist was given, using %d', quality_type, opt_dist);
end

% quality_type = 'wss_dd_dop';
%%%
if ~pc.progress.sensorspace.sensorcomb
    pc = sensorspace.sensorcomb(pc);
end
%%
write_log(' calculating %s quality values...', quality_type);
% calculate quality for every workspace point in every sensor combination
loop_display(pc.problem.num_positions, 10);
% val = zeros(pc.problem.num_positions, pc.problem.num_sensors);
val = cell(pc.problem.num_positions, 1);
for idw = 1:pc.problem.num_positions
%     sensor_flt = pc.problem.xt_ij(:,idw);
    sensor_flt = pc.problem.wp_s_idx{idw};
    distances = mb.distancePoints(pc.problem.W(:,idw), pc.problem.S(1:2, sensor_flt));
    d_scaled = 1-(distances'./pc.sensors.distance.max);
    val{idw} = 1-abs(d_scaled-(opt_dist/pc.sensors.distance.max));
%     val(idw, sensor_flt) = distances;
%     val(idw, ~sensor_flt) = inf;
end
% pc.problem.wp_q_dist = val;
write_log('...done ');
%%
pc.quality.(quality_type).val = val;
% pc.quality.(quality_type).valbw = val;
% pc.quality.(quality_type).valsum = valsum;
pc.progress.quality.(quality_type) = true;

return;
%% testing
close all; clearvars all; fclose all; clear write_log
pc = processing_configuration('sides4_nr0');
pc.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
pc.sensorspace.uniform_position_distance = 100*5;
pc.sensorspace.uniform_angle_distance = deg2rad(45/2);
pc.workspace.grid_position_distance = 100*5;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
%%
pc = quality.wss.dd_dop(pc, 4);
figure, draw.ws_qstats(pc, pc.quality.types.wss_dd_dop);
