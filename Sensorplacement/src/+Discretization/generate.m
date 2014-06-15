function [ discretization ] = generate( environment, config )
%GENERATE generates a discretization for a given environment by using the 
% parameters that are provided along with it
% requirements:
%   config.sensorspace : config of sensorspace
%   config.workspace   : config of workspace
%   config.sensor      : config of sensor
%   config.bpolyclip   : config of bpolyclip
%   config.visilibity  : config of visilibity
%   environment : representation of environment
% import Discretization.*
discretization = DataModels.discretization;

discretization.wpn = Discretization.Workspace.(config.workspace.type)(environment, config);

[discretization.sp, discretization.vfovs, discretization.vm] = Discretization.Sensorspace.(config.sensorspace.type)(environment, discretization.wpn, config);

discretization.num_sensors = size(discretization.sp, 2);
discretization.num_positions = size(discretization.wpn, 2);

[discretization.spo] = Discretization.Sensorspace.sameplace(discretization.sp, config.sensor.fov);

[discretization.sc, discretization.sc_wpn] = Discretization.Sensorspace.sensorcomb(discretization.vm, discretization.spo, config);

% discretization.wpn_sc = cellfun(@

discretization.num_comb = size(discretization.sc, 1);



return;
%% TESTING
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;

options.positions.additional = 0;
discretization = Discretization.generate(environment, config_discretization);


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

