function [input] = office_floor(num_sp, num_wpn)
%%
% clear variables;% functions;

if nargin < 3
    draw = false;
end
%%
% num_sp = 0;
% num_wpn = 0;

name = 'OfficeFloor';


lookupdir = sprintf('tmp/office_floor/discretization');

env = load('tmp\office_floor\environment\environment.mat');
environment = env.environment;

lookup_filename = [lookupdir filesep sprintf('%d_%d.mat', num_sp, num_wpn)];

    config_discretization = Configurations.Discretization.iterative;
    config_discretization.workspace.wall_distance = 200;
    % config_discretization.workspace.cell.length = [0 1000];
    config_discretization.workspace.positions.additional = num_wpn;
    config_discretization.sensorspace.poses.additional = num_sp;
    config_discretization.common.verbose = 0;
%%
if ~exist(lookup_filename, 'file')
%             num_sp =  0;
%             num_wpn = 10;
%             num_wpn = 650;
    %%%

    
    %%%  Calculate obstacle and initial poses that are only on convex corners on mountables
    %%% Poses on Boundary vertices
    comb_corners = cellfun(@(x) [circshift(x(:,1:2), 1, 1), x, circshift(x(:, 3:4), -1, 1)], environment.combined_edges, 'uniformoutput', false);
    comb_corners_placeable = cellfun(@(x, fx) [x(fx, 1:6); x(fx, 3:8)], comb_corners, environment.placable_edges, 'uniformoutput', false);
    comb_corners_pl_uni = cellfun(@(x) unique(x, 'rows'), comb_corners_placeable, 'uniformoutput', false);

    %%% Add intersections of obstacles with environment

    sensor_poses_boundary = Discretization.Sensorspace.place_sensors_on_corners(comb_corners_pl_uni{1}, config_discretization.sensor.directional(2), config_discretization.sensorspace.resolution.angular, false, true);
    %%%
    sensor_poses_mountables = cellfun(@(p) Discretization.Sensorspace.place_sensors_on_corners(p, config_discretization.sensor.directional(2), config_discretization.sensorspace.resolution.angular, false, false, true), comb_corners_pl_uni(2:end), 'uniformoutput', false);
    sensor_poses_mountables{1} = Discretization.Sensorspace.place_sensors_on_corners(comb_corners_pl_uni{2}, config_discretization.sensor.directional(2), config_discretization.sensorspace.resolution.angular, false, true, false);
    %%%
    flt_nonempty = cellfun(@(x) ~isempty(x), sensor_poses_mountables);
    sensor_poses_all = [sensor_poses_boundary, cell2mat(sensor_poses_mountables(flt_nonempty))];
    config_discretization.sensorspace.poses.initial = sensor_poses_all;

    discretization = Discretization.generate(environment, config_discretization);
    
    %%%
    config_quality = Configurations.Quality.diss;
    [quality] = Quality.generate(discretization, config_quality);
    
    input.discretization = discretization;
    input.quality = quality;
    input.num_sp = num_sp;
    input.num_wpn = num_wpn;
    input.timestamp = datestr(now,30);
    input.name = name;
    %%%
%     input.environment = environment;
%     Experiments.Diss.draw_input(input);
    %%
    save(lookup_filename, 'input');
       %         input.config.environment = config_environment;
    input.config.quality = config_quality;
else
    
    input = load(lookup_filename);
    input = input.input;
    
end
input.environment = environment;
    input.config.discretization = config_discretization;
input.parts = Environment.filter(input, input.environment.P_c);

return;
%%
input.environment = environment;
Experiments.Diss.draw_input(input);
%%
% num_sp_max =  500;
% num_wpn_max = 650;
num_wpns = 0:10:500;
num_sps =  0:10:500;
iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps);
write_log([], '#off');

for id_wpn = 1:numel(num_wpns)
    for id_sp = 1:numel(num_sps)
        num_wpn = num_wpns(id_wpn);
        num_sp = num_sps(id_sp);
        
        %%
%         num_wpn = 10;
%         num_sp = 10;
        
        Experiments.Diss.office_floor(num_sp, num_wpn);

        %%
        iteration = iteration + 1;
        if toc(tme)>next
            fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
            next = toc(tme)+stp;
        end
    end
end


