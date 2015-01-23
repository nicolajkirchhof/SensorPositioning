function filename = stcm(discretization, ~, config)
%%

import Optimization.Discrete.Models.*
% model = DataModels.optimizationmodel;

config.filename = Optimization.Discrete.Models.create_filename(discretization, config);
filename = config.filename;

config = Optimization.Discrete.Models.init(config);
Optimization.Discrete.Models.Objective.sum_sensors(discretization, config);
Optimization.Discrete.Models.Constraints.two_coverage(discretization, config);
Optimization.Discrete.Models.Constraints.sameplace(discretization, config);
Optimization.Discrete.Models.Binaries.sensors(discretization, config);
config = Optimization.Discrete.Models.finish(config);

Optimization.Discrete.Models.save(config);

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
filename = Optimization.Discrete.Models.stcm(discretization, [], config);
%%
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
solfile = Optimization.Discrete.Solver.cplex.startext(filename, cplex);
sol = Optimization.Discrete.Solver.cplex.read_solution_it(solfile);

