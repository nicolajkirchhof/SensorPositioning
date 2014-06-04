function discretization = iterative()
%% ITERATIVE configuration of iterative 

discretization = Configurations.Discretization.generic;
discretization.sensor = Configurations.Sensor.tpl;
discretization.sensorspace = Configurations.Sensorspace.iterative;
discretization.workspace = Configurations.Workspace.iterative;
discretization.type = Configurations.Discretization.get_types().iterative;

return;
%% TEST if assigned
% disc = Configurations.Discretization.iterative;
% log_test(Configurations. disc.sensor.type
