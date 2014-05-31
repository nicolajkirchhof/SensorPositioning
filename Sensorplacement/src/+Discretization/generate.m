function [ discretization ] = generate( requirements )
%GENERATE generates a discretization for a given environment by using the 
% parameters that are provided along with it
% requirements:
%   sensorspace : config of sensorspace
%   workspace   : config of workspace
%   sensor      : config of sensor
%   environment : representation of environment


   
switch options.sampling_technique
    case options.common.sampling_techniques.random
        error('not yet converted to new format');
    case {options.common.sampling_techniques.uniform, options.common.sampling_techniques.grid}
        options = workspace.uniform_positions(options);
    otherwise
        error('not implemented');
end    

options.workspace.number_of_positions = size(options.problem.W, 2);
options.problem.num_positions = size(options.problem.W, 2);
if options.workspace.coverage_technique == options.common.sampling_techniques.uniform
    options.problem.k = ones(options.problem.num_positions, 1)*options.workspace.coverage;
elseif options.workspace.coverage_technique == options.common.sampling_techniques.none
    options.problem.k = options.workspace.coverage;
else
    error('no k sampling technique defined');
end

options.progress.workspace.positions = true;


end

