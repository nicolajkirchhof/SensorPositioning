function [ quality_collection ] = split( discretization_collection,  quality )
%% SPLIT splits the quality according to the provided environments

quality_collection = cell(size(discretization_collection));
cla, hold on
for id_env = 1:numel(discretization_collection)
%%
%     id_env = 3;
    discretization_tmp = discretization_collection{id_env};

    quality_tmp = DataModels.quality();

    quality_tmp.ws.ids = quality.ws.ids(discretization_tmp.wpn_ids);
    quality_tmp.ws.val = quality.ws.val(discretization_tmp.wpn_ids);
    
    quality_tmp.wss.val = quality.wss.val(discretization_tmp.wpn_ids);
    quality_tmp.wss.valbw = quality.wss.valbw(discretization_tmp.sc_ids , :);
    quality_tmp.wss.valsum = quality.wss.valsum(discretization_tmp.sc_ids, :); 
  
    quality_collection{id_env} = quality_tmp;
end

return;
%% TESTING
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;
config_environment = Configurations.Environment.rpd;
environment_collection = Environment.decompose(environment, config_environment, true);

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;

[quality] = Quality.generate(discretization, config_quality);
%%
discretization_collection = Discretization.split(environment_collection, discretization);
% config_quality = Configurations.Quality.diss;
quality_collection = Quality.split(discretization_collection, quality);


%%
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe';
fun_solve = @(filename) Optimization.Discrete.Solver.cplex.run(filename, cplex);
filenames = {};
solutions = {};
config_models = Configurations.Optimization.Discrete.bspqm;
for id_dis = 1:numel(discretization_collection)
        discretization = discretization_collection{id_dis};
        quality = quality_collection{id_dis};
        filenames{id_dis} = Optimization.Discrete.Models.bspqm(discretization, quality, config_models);
        solutions{id_dis} = fun_solve(filenames{id_dis}); 
end
