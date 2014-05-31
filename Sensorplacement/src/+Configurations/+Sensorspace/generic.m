function sensorspace = generic()

sensorspace.type   = Configurations.Sensorspace.get_types().generic;

% %% generates the envelope to store the sensorspace data
% sensorspace.number_of_angles_per_position = 0;
% sensorspace.angles_sampling_technique = common.sampling_techniques.uniform;
% % only for random sampling
% % (1) pre = one random sampling before the positions are calculated
% % (2) within = sample new random angles for every sampled position
% sensorspace.angles_sampling_occurences = struct('pre', 1, 'within', 2);
% sensorspace.angles_sampling_occurence = sensorspace.angles_sampling_occurences.pre;
% % minimum distance between two angles that is allowed
% sensorspace.min_angle_distance = 0; % rad
% sensorspace.min_position_distance = 100; % mm
% sensorspace.max_position_distance = 300; % mm
% sensorspace.uniform_position_distance = 100; % mm
% sensorspace.uniform_angle_distance = deg2rad(9); % rad
% sensorspace.use_overhead_positions = false;
% sensorspace.position_sampling_technique = common.sampling_techniques.uniform; % random, uniform
% sensorspace.seed = 0;
% % min positions that have to be visible from each sensor in order to keep it in the visibility
% % matrix
% sensorspace.min_visible_positions = 1; 
% % sensor has to see at least an area of 1m2
% sensorspace.min_visible_area = 100000;
% % diameter below polygon parts are considered to be spikes
% sensorspace.spike_distance = 100; % 10 cm
