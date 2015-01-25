function [ filename ] = create_filename( discretization, config )
%CREATE_FILENAME Summary of this function goes here
%   Detailed explanation goes here

% uuid = char(java.util.UUID.randomUUID());
filename = sprintf('%s_%s_%d_%d_%d', config.type, config.name, discretization.num_sensors_additional,...
    discretization.num_positions_additional); %, uuid(1:8));
config.filename = [config.common.workdir '/' filename '.lp'];
filename = config.filename;


end

