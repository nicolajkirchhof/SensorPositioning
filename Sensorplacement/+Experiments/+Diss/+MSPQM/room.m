clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
options = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;

options.positions.additional = 0;
workspace_positions = Discretization.Workspace.iterative( environment, options );
Discretization.Workspace.draw(workspace_positions);

options.sensorspace.poses.additional = 0;
[sensor_poses, vfovs, vm] = Discretization.Sensorspace.iterative(environment, workspace_positions, options);
Discretization.Sensorspace.draw(sensor_poses);



