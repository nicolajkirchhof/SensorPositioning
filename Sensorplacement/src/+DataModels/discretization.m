function discrete = discretization()

%% generates struct in which all common problem variables are stored
discrete.wpn = []; % int64 [2,n] matrix where every point is defined by [x;y] 
discrete.sp = [];
discrete.vm = []; % visibility matrix [num_sensor_positions; num_workspace_positions]
discrete.vfovs = {}; % holds all visibility polygons
discrete.spo = []; % columns=sensor_ids, rows=overlappings in fov
discrete.sc = []; % [n 2] array with all relevant two combinations of sensors sorted
discrete.sc_wpn = []; % {num_positions} with max [num_comb, 1] arrays with indices of sensor combinations that sees the workspace points

% discrete.wp_s_idx = []; % {num_positions} with max [num_sensors, 1] arrays with indices of sensor combinations that sees the workspace points

% discrete.St_i = []; % sensor choice matrix has the form st_i = [s1_1 ... s1_n s2_1 ... sn_n];
% discrete.k = [];  % [num_positions 1] vector that holds the coverage neede in each point
% discrete.q_dir = []; % [num_positions 1] vector that holds the directional coverage values needed at each point
% discrete.r_j = [];


% discrete.sc_obj_mult = 0; % multiplier that is appendend to each sc variable
% discrete.sc_ij = []; % true for every sensor sensor combination that has a wp in their common fov

% discrete.sc_ind = []; % [n 1] array with linear indices of sc_idx for a [num_sensors num_sensors] matrix
% discrete.sc_wp_idx = {}; % [num_comb 1] cell array with indices of workspace points that are in fov of sensor pair
% discrete.sp_idx = []; % cell array with indices of discrete.S that have the same x,y coordinates

% discrete.q_sin = {}; % [num_comb 1] cell array with q_sin quality values for s1,s2 combinations of workspace points in sc_wp_idx
% discrete.q_dsub_scale = []; % holds the objective scale of the directional sub values
discrete.num_sensors = [];
discrete.num_positions = [];
discrete.num_comb = [];
% discrete.quality.distance.min = 0;


%%% NOT NEEDED
% discrete.ct = []; % cost of sensor type t
% discrete.t_sum = []; % number of different sensor types
% dis.model.directional_sub.quality.min = 0;
