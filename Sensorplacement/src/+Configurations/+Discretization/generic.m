function discretization = generic()
%% GENERIC generic configuration of discretization includes
% sensorspace 
% workspace
% sensor 


discretization.sensorspace = Configurations.Sensorspace.generic;
discretization.workspace = Configurations.Workspace.generic;
discretization.sensor = Configurations.Sensor.generic;
discretization.type = Configurations.Discretization.get_types().generic;

% return;

%%
