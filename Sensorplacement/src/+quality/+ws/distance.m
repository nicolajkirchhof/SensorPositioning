function [val, ids] = distance(discretization, config)
% Loops through all workspace points and calculates the distance to all sensors

[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
quality_type = [model_prefix '_' model_name];

% if nargin < 2
%     config = 0;
%     warning('%s no opt_dist was given, using %d', quality_type, config);
% end
% discretization = discretization;

% quality_type = 'wss_dd_dop';
%%%
% if ~.progress.sensorspace.sensorcomb
%      = sensorspace.sensorcomb();
% end
%%
write_log(' calculating %s quality values...', quality_type);
% calculate quality for every workspace point in every sensor combination
num_positions = size(discretization.vm, 2);
loop_display(num_positions, 10);
% val = zeros(num_positions, .problem.num_sensors);
val = cell(num_positions, 1);
ids = cell(num_positions, 1);
for idw = 1:num_positions
%     sensor_flt = .problem.xt_ij(:,idw);
    ids{idw} = find(discretization.vm(:, idw));
    distances = mb.distancePoints(discretization.wpn(:,idw), discretization.sp(1:2, ids{idw}));
    val{idw} = 1 - (abs(distances' - config.sensor.distance_optimal)/(config.sensor.distance(2)-config.sensor.distance_optimal));
%     val(idw, sensor_flt) = distances;
%     val(idw, ~sensor_flt) = inf;
end
% wpnp_q_dist = val;
write_log('...done ');
%%
% quality =
% .quality.(quality_type).valbw = val;
% .quality.(quality_type).valsum = valsum;
% .progress.quality.(quality_type) = true;

return;

%% TESTS
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality, quality_ids] = Quality.WS.distance(discretization, config_quality);

% 
% %% testing
% close all; clearvars all; fclose all; clear write_log
%  = processing_configuration('sides4_nr0');
% .environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
% .sensorspace.uniform_position_distance = 100*5;
% .sensorspace.uniform_angle_distance = deg2rad(45/2);
% .workspace.grid_position_distance = 100*5;
% .sensors.distance.min = 0;
% .sensors.distance.max = 6000;
% %%
%  = quality.wss.dd_dop(, 4);
% figure, draw.ws_qstats(, .quality.types.wss_dd_dop);
