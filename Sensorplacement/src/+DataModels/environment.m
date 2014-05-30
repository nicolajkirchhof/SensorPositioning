function env = environment()
%% ENVIRONMENT Defines the 2d environment of a sensor placement problem
%% generates the envelope to store the environment data
env.file = [];
env.mountable.poly = {}; % all polys on which sensors can be mounted
env.obstacles.poly = {}; % all obstacles where no sensors can be mounted and that block the view
env.occupied.poly  = {}; % all places where no workspace points can be created
env.walls.poly      = {}; % the sourrounding walls as a polygon
env.walls.ring      = {}; % the inner wall in ccw orientation
env.spike_distance = 10; % 1 cm
env.combined.poly = {}; % combined poly where walls build the
