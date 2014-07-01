        function [ discretization_collection ] = split( environment_collection, discretization )
%SPLIT splits the discretization according to the env_collection

discretization_collection = {};
config_environment = Configurations.Bpolyclip.environment;
cla, hold on
for id_env = 1:numel(environment_collection)
%%
%     id_env = 3;
    environment_tmp = environment_collection{id_env};
    % does the env contain wpn
    is_wpn_in = binpolygon(discretization.wpn, environment_tmp.boundary.ring);
    if ~any(is_wpn_in)
        continue;
    end

    discretization_tmp = DataModels.discretization();
    discretization_tmp.wpn = discretization.wpn(:, is_wpn_in);
    discretization_tmp.wpn_ids = find(is_wpn_in);

    sp_vis = any(discretization.vm(:, is_wpn_in), 2);
    discretization_tmp.sp_ids = find(sp_vis);
    discretization_tmp.sp = discretization.sp(:, sp_vis);
    discretization_tmp.vm = discretization.vm(sp_vis, is_wpn_in);
    discretization_tmp.vfovs = discretization.vfovs(sp_vis);
    discretization_tmp.spo = discretization.spo(sp_vis, sp_vis);

    sc_vis = any(discretization.sc_wpn(:, is_wpn_in), 2);
    discretization_tmp.sc_ids = find(sc_vis);
    sc_tmp = discretization.sc(sc_vis, :);
    for id_map = 1:numel(discretization_tmp.sp_ids)
        id_orig = discretization_tmp.sp_ids(id_map);
        sc_tmp(sc_tmp == id_orig) = id_map;
    end
    discretization_tmp.sc = sc_tmp;
    discretization_tmp.sc_wpn = discretization.sc_wpn(sc_vis, is_wpn_in);

    discretization_tmp.num_comb = sum(sc_vis);
    discretization_tmp.num_positions = sum(is_wpn_in);
    discretization_tmp.num_sensors = sum(sp_vis);
    discretization_tmp.id = id_env;
    discretization_tmp.environment = environment_tmp;

    discretization_collection{end+1} = discretization_tmp;   
    
    mb.drawPolygon(environment_tmp.boundary.ring);
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
environment_collection = Environment.Decompose.rpd(environment, true);

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

discretization_collection = Discretization.split(environment_collection, discretization);

config_quality = Configurations.Quality.diss;
quality_collection = cell(size(discretization_collection));
%%
for id_dis = 1:numel(discretization_collection)
    quality_collection{id_dis} = Quality.generate(discretization_collection{id_dis}, config_quality);
end

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

%%% OLD CODE   
% switch options.sampling_technique
%     case options.common.sampling_techniques.random
%         error('not yet converted to new format');
%     case {options.common.sampling_techniques.uniform, options.common.sampling_techniques.grid}
%         options = workspace.uniform_positions(options);
%     otherwise
%         error('not implemented');
% end    
% 
% options.workspace.number_of_positions = size(options.problem.W, 2);
% options.problem.num_positions = size(options.problem.W, 2);
% if options.workspace.coverage_technique == options.common.sampling_techniques.uniform
%     options.problem.k = ones(options.problem.num_positions, 1)*options.workspace.coverage;
% elseif options.workspace.coverage_technique == options.common.sampling_techniques.none
%     options.problem.k = options.workspace.coverage;
% else
%     error('no k sampling technique defined');
% end
% 
% options.progress.workspace.positions = true;
% 
% 
% end

