function angles = angles(pc)

switch pc.sensorspace.angles_sampling_technique
    case pc.common.sampling_techniques.random
        angles = rand(1, pc.sensorspace.number_of_angles_per_position)*pi;
    case pc.common.sampling_techniques.uniform
        angles = linspace(0, pi, round(pi/pc.sensorspace.uniform_angle_distance));
    otherwise
        error('not implemented');
end
% 
% function angles = generate_random_sensorspace_angles(pc)
% 
%   
% 
% 
% function angles = generate_uniform_sensorspace_angles(pc)
