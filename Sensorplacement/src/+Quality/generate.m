function [ quality ] = generate( discretization, config )
%GENERATE generates a discretization for a given environment by using the 
% parameters that are provided along with it
% requirements:
%   config.ws  : type of ws quality
%   config.wss : type of wss quality
% import Discretization.*

quality_tmp = Quality.WS.(config.ws)(discretization, config);

quality = Quality.WSS.(config.wss)(discretization, config);
quality.ws = quality_tmp.ws; 


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

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality);

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

