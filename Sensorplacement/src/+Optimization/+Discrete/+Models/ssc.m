function filename = ssc(discretization, ~, config)
%% filename = ssc(discretization, quality, config) 
%   The single sensor coverage model

% import Optimization.Discrete.Models.*
% model = DataModels.optimizationmodel;

config.filename = Optimization.Discrete.Models.create_filename(discretization, config);
filename = config.filename;

config = Optimization.Discrete.Models.init(config);
Optimization.Discrete.Models.Objective.sum_sensors(discretization, config);
Optimization.Discrete.Models.Constraints.k_coverage(discretization, config);
% Constraints.two_coverage(discretization, config);
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
config_environment.filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(config_environment.filename);
Environment.draw(environment);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality); 
%%
config_model = Configurations.Optimization.Discrete.ssc;
% config_model.quality.min = 1.1;
config_model.name = 'P1';
% config_models
filename = Optimization.Discrete.Models.ssc(discretization, quality, config_model);
model.filename = filename;

%%
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
solfile = Optimization.Discrete.Solver.cplex.startext(filename, cplex);
sol = Optimization.Discrete.Solver.cplex.read_solution_it(solfile);

sel_sensors = find(sol.x);
hold on;
mb.drawPoint(discretization.sp(1:2, sel_sensors));
mb.drawPolygon(discretization.vfovs(sel_sensors));
%%
solution = DataModels.solution(environment, discretization, quality, model,...
    config_environment, config_discretization, config_quality, config_model,...
    sol);


