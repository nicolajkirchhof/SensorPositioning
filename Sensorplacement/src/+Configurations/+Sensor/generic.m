function sensor = generic()
%% GENERIC generates the envelope to store the sensor data
% options included :
% distance    = [nan nan] : range in mm
% directional = [nan nan] : directional range, first is min detection ratio max 
%   is the fov
% fct_fov : returns the fov in degree

% sensor.fov          = nan; % in degree
% sensor.angle        = deg2rad(sensor.fov); % the radian rep of fov
sensor.distance    = [nan nan]; % in mm
sensor.directional = [nan nan]; % in rad 
% sensor.aoa_error = deg2rad(8); % the angular error that is used to calculate quality constraints
% sensor.types   = Configurations.Sensor.get_types();
sensor.type  = Configurations.Sensor.get_types().generic;


