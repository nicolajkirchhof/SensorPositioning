function env = environment()
%% ENVIRONMENT Defines the 2d environment of a sensor placement problem
% generates the envelope to store the environment data which contains
% file           : filename of the loaded environment
% mountable      : {} all rings on which sensors can be mounted
% obstacles      : {} all rings of obstacles where no sensors can be mounted and that block the view
% occupied       : {} all rings where no workspace points can be created
% walls          : {} the sourrounding walls as a polygon
% boundary       : {} the inner wall in ccw orientation
% spike_distance : {} the spike distance that is used to merge polys
% combined       : {} combined poly where walls build the

env.file      = [];
env.mountable = {}; % all polys on which sensors can be mounted
env.obstacles = {}; % all obstacles where no sensors can be mounted and that block the view
env.occupied  = {}; % all places where no workspace points can be created
env.walls     = {}; % the sourrounding walls as a polygon
env.boundary  = DataModels.boundary; % the inner wall in ccw orientation
env.combined  = {}; % combined poly where walls build the
