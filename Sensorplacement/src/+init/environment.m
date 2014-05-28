function pc = processing_configuration(name)
pc.name = name;
pc.tag = datestr(now,30);

wd = ['tmp/' name];
pc.common.workdir = wd;
if ~exist(pc.common.workdir, 'dir')
    mkdir(pc.common.workdir);
end

%%
pc.common.sampling_techniques = struct('none', 0,'random', 1, 'grid', 2, 'uniform', 3, 'iterative', 4);
%Robustness constant
pc.common.epsilon = 1e-10; % 5mm
%Snap distance (distance within which an observer location will be snapped to the
%boundary before the visibility polygon is computed)
pc.common.snap_distance = 10;
pc.common.valid_poly_area = 10000; % min area for which polygon intersections are considered = 10cm2
% exactness of the created polylines
pc.common.polyline_verticies = 10;
pc.common.grid_limit = 1; % 1 mm
pc.common.spike_distance = 10; % 1 cm
pc.common.is_logging = true; 
pc.common.verbose = true; % should additional output like progress bars be displayed
pc.common.is_display = true; % should calculated properties be displayed on screen
pc.common.debug = false; % additional debug infos, plots and more
pc.common.check_polygons = true;
pc.common.bpolyclip_batch_options = {pc.common.check_polygons, pc.common.spike_distance, pc.common.grid_limit, pc.common.verbose};
pc.common.bpolyclip_options = {pc.common.check_polygons, pc.common.spike_distance, pc.common.grid_limit};
pc.common.tmpfile.wp_sc_idx.name = [wd filesep pc.name pc.tag '.tmp']; %filename of the used tmpfile
pc.common.tmpfile.wp_sc_idx.fid = 0; %filename of the used tmpfile
pc.common.workmem = 5e8; % size of data to hold in ram before writing to tmpfile default 500MB
pc.common.linesize = 300; % number of chars per line must be < 500
pc.common.linecache = 100000; % number lines to cache before write
pc.common.logname = [];
pc.common.timing = {};

%% generates the envelope to store the environment data
pc.environment.file = [];
pc.environment.mountable.poly = {}; % all polys on which sensors can be mounted
pc.environment.obstacles.poly = {}; % all obstacles where no sensors can be mounted and that block the view
pc.environment.occupied.poly  = {}; % all places where no workspace points can be created
pc.environment.walls.poly      = {}; % the sourrounding walls as a polygon
pc.environment.walls.ring      = {}; % the inner wall in ccw orientation
pc.environment.spike_distance = 10; % 1 cm
pc.environment.combined.poly = {}; % combined poly where walls build the outer boundary and all obstacles
% and mountables are subtracted
pc.environment.combined.unmountable.edges = {}; % holds the info of all non mountable edges
pc.environment.combined.unmountable.points = {}; % all edge points that lie between two non mountable edges
pc.environment.decompositon.convex.splitting.types = {'centroid_splitting'};
pc.environment.decompositon.convex.types = {'obstacle_expansion', 'hertel_mehlhorn', 'keil_snoeyink'};
pc.environment.decompositon.convex.obstacle_expansion.polys = [];
pc.environment.decompositon.convex.obstacle_expansion.mountable_edges = [];
pc.environment.decompositon.convex.obstacle_expansion.unmountable.points = [];
pc.environment.decompositon.convex.obstacle_expansion.split.polys = [];
pc.environment.decompositon.convex.obstacle_expansion.split.mountable_edges  = [];
pc.environment.decompositon.convex.obstacle_expansion.split.mountable_polys  = [];
pc.environment.decompositon.convex.obstacle_expansion.split_needed = [];
pc.environment.decompositon.convex.hertel_mehlhorn.polys = [];
pc.environment.decompositon.convex.hertel_mehlhorn.mountable_edges = [];
pc.environment.decompositon.convex.hertel_mehlhorn.unmountable.points = [];
pc.environment.decompositon.convex.hertel_mehlhorn.split.polys = [];
pc.environment.decompositon.convex.hertel_mehlhorn.split.mountable_edges  = [];
pc.environment.decompositon.convex.hertel_mehlhorn.split.mountable_polys  = [];
pc.environment.decompositon.convex.hertel_mehlhorn.split_needed = [];
pc.environment.decompositon.convex.keil_snoeyink.polys = [];
pc.environment.decompositon.convex.keil_snoeyink.mountable_edges = [];
pc.environment.decompositon.convex.keil_snoeyink.unmountable.points = [];
pc.environment.decompositon.convex.keil_snoeyink.split.polys = [];
pc.environment.decompositon.convex.keil_snoeyink.split.mountable_edges  = [];
pc.environment.decompositon.convex.keil_snoeyink.split.mountable_polys  = [];
pc.environment.decompositon.convex.keil_snoeyink.split_needed = [];
pc.environment.decompositon.triangular.types = {'ear_clipping', 'opt_length', 'monotone'};
pc.environment.decompositon.triangular.ear_clipping.polys = [];
pc.environment.decompositon.triangular.ear_clipping.mountable_edges = [];
pc.environment.decompositon.triangular.ear_clipping.unmountable.points = [];
pc.environment.decompositon.triangular.opt_length.polys = [];
pc.environment.decompositon.triangular.opt_length.mountable_edges = [];
pc.environment.decompositon.triangular.opt_length.unmountable.points = [];
pc.environment.decompositon.triangular.monotone.polys = [];
pc.environment.decompositon.triangular.monotone.mountable_edges = [];
pc.environment.decompositon.triangular.monotone.unmountable.points = [];
pc.environment.decompositon.triangular.delauny.polys = [];
pc.environment.decompositon.triangular.delauny.mountable_edges = [];
pc.environment.decompositon.triangular.delauny.unmountable.points = [];

%% generates struct in which all common model variables are stored
% Just a hint to the cplex values
%pc.model.cplex.enable = false; % creation of cplex Model matrices
%%
%% TODO: add dirdist_comb
model_types = {'ws', 'wss', 'it'};
pc.model.filetypes = {'obj', 'st', 'bounds', 'bin', 'general'}; % types of tmp files
pc.model.header = []; % user defined header of comments to file e.g. \Problem name: xyz
for mt = model_types
    mt = mt{1};
    fn = dir(['src' filesep '+model' filesep '+' mt filesep '*.m']);
    % ws_quality_types = {'ws_distance'};
    % ws_quality_tags = {'_wsdist'};
    % ws_quality_funs = {@quality.dist}
    for idws = 1:numel(fn)
        [~, name, ~] = fileparts(fn(idws).name);
        modname = [mt '_' name];
        tag = ['_' name];
        pc.model.types.(modname) = modname;
        pc.model.(modname).id = 0;
        pc.model.(modname).tag = tag;
        pc.model.(modname).enable = false;
        pc.model.(modname).quality.min = 0;
        pc.model.(modname).quality.max = 1;
        pc.model.(modname).quality.reject = 0;
        for mtq = model_types            
        pc.model.(modname).quality.(mtq{1}).name = [];
        pc.model.(modname).quality.(mtq{1}).param = 1;
        end          
        pc.model.(modname).file.open = false;
        for modft = pc.model.filetypes
        modft = modft{1};
        pc.model.(modname).(modft).filename = {}; % cell array of files to be combined
        pc.model.(modname).(modft).fid = []; % fids of files
        pc.model.(modname).(modft).enable = true; % fids of files
        end
    end
end

%% generates struct in which all common problem variables are stored
pc.problem.W = []; % [5,n] matrix where every point is defined by [x;y;q;w;k] q=min quality, w=weight
pc.problem.wp_sc_idx = []; % {num_positions} with max [num_comb, 1] arrays with indices of sensor combinations that sees the workspace points
pc.problem.wp_s_idx = []; % {num_positions} with max [num_sensors, 1] arrays with indices of sensor combinations that sees the workspace points
% pc.problem.wp_q_sin = {}; % {num_positions} cell array with qualities of sc that are in wp_sc_idx
% pc.problem.wp_q_dist = []; % [num_positions num_sensor] array with distances between sensors and workspace points
% pc.problem.wp_q_d1d2sin = []; % [num_positions num_sensor] array with distances between sensors and workspace points
% pc.problem.wp_q_sum = []; % [num_positions 1] array with sum of qualities for every point
% [4,n] matrix where every point is defined by [x;y;phi;k] k=sensor type
% the sensor fov ranges from phi to phi+pc.sensors.fov
pc.problem.S = [];
pc.problem.xt_ij = []; % visibility matrix [num_sensor_positions; num_workspace_positions]
pc.problem.ct = []; % cost of sensor type t
pc.problem.t_sum = []; % number of different sensor types
pc.problem.St_i = []; % sensor choice matrix has the form st_i = [s1_1 ... s1_n s2_1 ... sn_n];
pc.problem.k = [];  % [num_positions 1] vector that holds the coverage neede in each point
pc.problem.q_dir = []; % [num_positions 1] vector that holds the directional coverage values needed at each point
pc.problem.r_j = [];
% holds all visibility polygons
pc.problem.V = {};
pc.problem.sc_obj_mult = 0; % multiplier that is appendend to each sc variable
% pc.problem.sc_ij = []; % true for every sensor sensor combination that has a wp in their common fov
pc.problem.sc_idx = []; % [n 2] array with all relevant two combinations of sensors sorted
% pc.problem.sc_ind = []; % [n 1] array with linear indices of sc_idx for a [num_sensors num_sensors] matrix
% pc.problem.sc_wp_idx = {}; % [num_comb 1] cell array with indices of workspace points that are in fov of sensor pair
% pc.problem.sp_idx = []; % cell array with indices of pc.problem.S that have the same x,y coordinates
pc.problem.sp_ij = []; % columns=sensor_ids, rows=overlappings in fov
pc.problem.q_sin = {}; % [num_comb 1] cell array with q_sin quality values for s1,s2 combinations of workspace points in sc_wp_idx
% pc.problem.q_dsub_scale = []; % holds the objective scale of the directional sub values
pc.problem.num_sensors = [];
pc.problem.num_positions = [];
pc.problem.num_comb = [];
pc.problem.quality.distance.min = 0;

pc.model.directional_sub.quality.min = 0;

%% quality definitions
model_types = {'ws', 'wss'};
for mt = model_types
    mt = mt{1};
    fn = dir(['src' filesep '+quality' filesep '+' mt filesep '*.m']);
    % ws_quality_types = {'ws_distance'};
    % ws_quality_tags = {'_wsdist'};
    % ws_quality_funs = {@quality.dist}
    for idws = 1:numel(fn)
        [~, name, ~] = fileparts(fn(idws).name);
        qname = [mt '_' name];
        tag = ['_' qname];
        pc.quality.types.(qname) = qname;
        pc.quality.(qname).name = name;
        pc.quality.(qname).type = name;
        pc.quality.(qname).tag = tag;
        pc.quality.(qname).fct = eval(['@quality.' mt '.' name ]);
        pc.quality.(qname).val = [];
        pc.quality.(qname).valbw = [];
    end
end
% selected quality that is applied
pc.quality.selected = [];

%% generates the envelope to store the sensorspace data
pc.sensorspace.number_of_angles_per_position = 0;
pc.sensorspace.angles_sampling_technique = pc.common.sampling_techniques.uniform;
% only for random sampling
% (1) pre = one random sampling before the positions are calculated
% (2) within = sample new random angles for every sampled position
pc.sensorspace.angles_sampling_occurences = struct('pre', 1, 'within', 2);
pc.sensorspace.angles_sampling_occurence = pc.sensorspace.angles_sampling_occurences.pre;
% minimum distance between two angles that is allowed
pc.sensorspace.min_angle_distance = 0; % rad
pc.sensorspace.min_position_distance = 100; % mm
pc.sensorspace.max_position_distance = 300; % mm
pc.sensorspace.uniform_position_distance = 100; % mm
pc.sensorspace.uniform_angle_distance = deg2rad(9); % rad
pc.sensorspace.use_overhead_positions = false;
pc.sensorspace.position_sampling_technique = pc.common.sampling_techniques.uniform; % random, uniform
pc.sensorspace.seed = 0;
% min positions that have to be visible from each sensor in order to keep it in the visibility
% matrix
pc.sensorspace.min_visible_positions = 1; 
% sensor has to see at least an area of 1m2
pc.sensorspace.min_visible_area = 100000;
% diameter below polygon parts are considered to be spikes
pc.sensorspace.spike_distance = 100; % 10 cm

%% generates the envelope to store the sensor data
pc.sensors.fov = 45; % in degree
pc.sensors.angle = deg2rad(pc.sensors.fov); % the radian rep of fov
pc.sensors.distance.max = 10000; % in mm
pc.sensors.distance.min = 0; % in mm
% pc.sensors.quality.distance.max = 0.5; % on a distance of 50% of the sensors the quality is best
% pc.sensors.quality.distance.scale = 0.5; % max influence of distance quality
pc.sensors.aoa_error = deg2rad(8); % the angular error that is used to calculate quality constraints
% pc.sensors.dist_error =  % do I need it?

%% generates the envelope to store the workspace data
pc.workspace.number_of_positions = 100;
pc.workspace.min_position_distance = 300;
pc.workspace.max_position_distance = 300;
pc.workspace.seed = 0;
pc.workspace.grid_position_distance = 200;
pc.workspace.sampling_technique = pc.common.sampling_techniques.grid; % random, grid
pc.workspace.x_axis_grid_distance = 100;
pc.workspace.y_axis_grid_distance = 100;
pc.workspace.wall_distance = 100;
% pc.workspace.quality.min = 0.6; % [0 .. 1] min quality
% pc.workspace.quality_technique = pc.common.sampling_techniques.uniform;
% pc.workspace.priority = 1; %uniform priority
% pc.workspace.priority_technique = pc.common.sampling_techniques.uniform;
pc.workspace.coverage = 2; % uniform coverage
pc.workspace.coverage_technique = pc.common.sampling_techniques.uniform;


%% progress, has to be defined last

pc.progress.environment.load = false;
pc.progress.environment.combine = false;

pc.progress.heuristic.cutoffs = false;
pc.progress.heuristic.placement = false;

pc.progress.model.init = false;
for type = fieldnames(pc.model.types)'
    type = type{1};
    pc.progress.model.(type) = false;
end
pc.progress.sensorspace.sensorcomb = false;
pc.progress.sensorspace.sameplace = false;
pc.progress.sensorspace.positions = false;
pc.progress.sensorspace.visibility = false;
pc.progress.workspace.positions = false;

for type = fieldnames(pc.quality.types)'
    type = type{1};
    pc.progress.quality.(type) = false;
end
