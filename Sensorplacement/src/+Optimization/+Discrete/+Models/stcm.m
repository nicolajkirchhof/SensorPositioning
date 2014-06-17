function filename = stcm(discretization, config)
%%

import Optimization.Discrete.Models.*
% model = DataModels.optimizationmodel;

filename = sprintf('%s_%s_%d_%d_%d', config.type, config.name, discretization.num_sensors,...
    discretization.num_positions, discretization.num_comb);
config.filename = [config.common.workdir '/' filename '.lp'];

config = init(config);
Objective.sum_sensors(discretization, config);
Constraints.two_coverage(discretization, config);
Binaries.sensors(discretization, config);
config = finish(config);

save(config);

%  = model.ws.coverage();
%  = model.save();
% start_cplex(.model.lastsave);
% s = read_solution(.model.lastsave);
% draw.solution(, s);
return;
%% TEST

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
[quality] = Quality.generate(discretization, config_quality); 

config = Configurations.Optimization.Discrete.stcm;
config.name = 'P1';
filename = Optimization.Discrete.Models.stcm(discretization, config);



