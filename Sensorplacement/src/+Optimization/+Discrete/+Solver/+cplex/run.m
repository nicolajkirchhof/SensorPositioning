function [solution] = run(filename, cplex)

import Optimization.Discrete.Solver.cplex.*
%
[solutionfile, logfile] = start(filename, cplex);

solution = DataModels.solution();
if exist(solutionfile, 'file')
    solution = Optimization.Discrete.Solver.cplex.read_solution(solutionfile); 
end

% solution.log = DataModels.optimizationlog();
if exist(logfile, 'file')
    solution = Optimization.Discrete.Solver.cplex.read_log(logfile, solution);   
end

% solution.solvingtime = solution.log.elapsedtime;

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

config = Configurations.Optimization.Discrete.bspqm;
config.name = 'P1';
filename = Optimization.Discrete.Models.bspqm(discretization, quality, config);
%%%
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
[solution] = Optimization.Discrete.Solver.cplex.run(filename, cplex);


