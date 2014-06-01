close all; 
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config = Configurations.Discretization.iterative;

environment = Environment.load(filename);
options = config.workspace;
base_workspace_positions = Discretization.Workspace.iterative( environment, options );


