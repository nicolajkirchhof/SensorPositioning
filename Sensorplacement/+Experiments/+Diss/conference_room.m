function [input] = conference_room(num_sp, num_wpn, draw)
%%
% clear variables;% functions;

if nargin < 3
    draw = false;
end

name = 'ConferenceRoom';
workdir = sprintf('tmp/conference_room');
filename = 'res\floorplans\P1-Seminarraum.dxf';
Configurations.Common.generic(name, workdir);

environment = Environment.load(filename);
% Environment.draw(environment);

%%
%         num_sp =  0;
%         num_wpn = 0;
config_discretization = Configurations.Discretization.iterative;
config_discretization.workspace.wall_distance = 200;
% config_discretization.workspace.cell.length = [0 1000];
config_discretization.workspace.positions.additional = num_wpn;
config_discretization.sensorspace.poses.additional = num_sp;
config_discretization.common.verbose = 0;
discretization = Discretization.generate(environment, config_discretization);

%%%
config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality);

input.discretization = discretization;
input.environment = environment;
input.quality = quality;
%         input.config.environment = config_environment;
input.config.discretization = config_discretization;
input.config.quality = config_quality;
input.timestamp = datestr(now,30);
input.name = name;

%     %%%
% if draw
%     maxval = cellfun(@max, input.quality.wss.val);
%     figure;
% %     cla;
%     Discretization.draw(discretization, environment);
%     
%     axis equal;
%     xlim([0 4000]);
%     ylim([800 8500]);
%     scatter(input.discretization.wpn(1,:)', input.discretization.wpn(2,:)', [], maxval, 'fill');
%     colorbar;
%     title(sprintf('Num SP %d, Num WPN %d, MinQ %g', num_sp, num_wpn, min(maxval)));
% end

