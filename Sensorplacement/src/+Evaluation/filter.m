function [flt_discretization, flt_quality] = filter(solution, discretization, config)

sensors_selected = sort(solution.sensors_selected);
% sensors_selected_map = 1:numel(sensors_selected);
flt_discretization = discretization;
flt_discretization.sp = discretization.sp(:, sensors_selected);
flt_discretization.vm = discretization.vm(sensors_selected, :);
flt_discretization.vfovs = discretization.vfovs(sensors_selected);
%%
flt_discretization.spo = discretization.spo(sensors_selected, sensors_selected);
[in1] = ismember(discretization.sc(:,1), sensors_selected);
[in2] = ismember(discretization.sc(:,2), sensors_selected);

is_in = in1&in2;
%%%
flt_discretization.sc_wpn = discretization.sc_wpn(is_in, :);
flt_discretization.sc = discretization.sc(is_in, :);
for ids = 1:numel(sensors_selected)
    flt_discretization.sc(flt_discretization.sc == sensors_selected(ids)) = ids;
end

%%
% not_in = flt_discretization.sc>numel(sensors_selected);
% flt_invalid = logical(sum(not_in, 2));
% flt_discretization.sc(flt_invalid, :) = [];
% flt_discretization.sc_wpn(flt_invalid, :) = [];
flt_discretization.num_comb = size(flt_discretization.sc_wpn, 1);
flt_discretization.num_sensors = numel(sensors_selected);
%%
if nargin < 3
    config = Configurations.Quality.diss;
end
flt_quality = Quality.WSS.kirchhof(flt_discretization, config);
%%
return;
%%
clear variables
num_wpn = 0;
num_sp = 0;

input = Experiments.Diss.conference_room(num_sp, num_wpn, true);
%%%
input.config.optimization = Configurations.Optimization.Discrete.gco;
input.config.optimization.name = input.name;
output_filename = sprintf('tmp/conference_room/gco__%d_%d_%d.mat', input.discretization.num_sensors, input.discretization.num_positions, input.discretization.num_comb);
solution = Optimization.Discrete.Greedy.gco(input.discretization, input.quality, input.config.optimization);
input.solution = solution;

discretization = input.discretization;
config = input.config.discretization;

%%
Evaluation.filter(solution, discretization, config);
