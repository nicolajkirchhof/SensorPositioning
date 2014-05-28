function m = model(pc, name)
m.name = name;
m.uuid = datestr(now,30);

wd = ['tmp/' name];
m.common.workdir = wd;
if ~exist(m.common.workdir, 'dir')
    mkdir(m.common.workdir);
end

%%
m.common.sampling_techniques = struct('none', 0,'random', 1, 'grid', 2, 'uniform', 3, 'iterative', 4);
%Robustness constant
m.common.epsilon = 1e-10; % 5mm
%Snap distance (distance within which an observer location will be snapped to the
%boundary before the visibility polygon is computed)
m.common.snap_distance = 10;
m.common.valid_poly_area = 10000; % min area for which polygon intersections are considered = 10cm2
% exactness of the created polylines
m.common.polyline_verticies = 10;
m.common.grid_limit = 1; % 1 mm
m.common.spike_distance = 10; % 1 cm
m.common.is_logging = true; 
m.common.verbose = true; % should additional output like progress bars be displayed
m.common.is_display = true; % should calculated properties be displayed on screen
m.common.debug = false; % additional debug infos, plots and more
m.common.check_polygons = true;
m.common.bpolyclip_batch_options = {m.common.check_polygons, m.common.spike_distance, m.common.grid_limit, m.common.verbose};
m.common.bpolyclip_options = {m.common.check_polygons, m.common.spike_distance, m.common.grid_limit};
m.common.tmpfile.wp_sc_idx.name = [wd filesep m.name m.tag '.tmp']; %filename of the used tmpfile
m.common.tmpfile.wp_sc_idx.fid = 0; %filename of the used tmpfile
m.common.workmem = 5e8; % size of data to hold in ram before writing to tmpfile default 500MB
m.common.linesize = 300; % number of chars per line must be < 500
m.common.linecache = 100000; % number lines to cache before write
m.common.logname = [];
m.common.timing = {};

%% generates the envelope to store the environment data
m.environment.file = [];
m.environment.mountable.poly = {}; % all polys on which sensors can be mounted
m.environment.obstacles.poly = {}; % all obstacles where no sensors can be mounted and that block the view
m.environment.occupied.poly  = {}; % all places where no workspace points can be created
m.environment.walls.poly      = {}; % the sourrounding walls as a polygon
m.environment.walls.ring      = {}; % the inner wall in ccw orientation
m.environment.spike_distance = 10; % 1 cm
m.environment.combined.poly = {}; % combined poly where walls build the outer boundary and all obstacles
% and mountables are subtracted
m.environment.combined.unmountable.edges = {}; % holds the info of all non mountable edges
m.environment.combined.unmountable.points = {}; % all edge points that lie between two non mountable edges
m.environment.decompositon.convex.splitting.types = {'centroid_splitting'};
m.environment.decompositon.convex.types = {'obstacle_expansion', 'hertel_mehlhorn', 'keil_snoeyink'};
m.environment.decompositon.convex.obstacle_expansion.polys = [];
m.environment.decompositon.convex.obstacle_expansion.mountable_edges = [];
m.environment.decompositon.convex.obstacle_expansion.unmountable.points = [];
m.environment.decompositon.convex.obstacle_expansion.split.polys = [];
m.environment.decompositon.convex.obstacle_expansion.split.mountable_edges  = [];
m.environment.decompositon.convex.obstacle_expansion.split.mountable_polys  = [];
m.environment.decompositon.convex.obstacle_expansion.split_needed = [];
m.environment.decompositon.convex.hertel_mehlhorn.polys = [];
m.environment.decompositon.convex.hertel_mehlhorn.mountable_edges = [];
m.environment.decompositon.convex.hertel_mehlhorn.unmountable.points = [];
m.environment.decompositon.convex.hertel_mehlhorn.split.polys = [];
m.environment.decompositon.convex.hertel_mehlhorn.split.mountable_edges  = [];
m.environment.decompositon.convex.hertel_mehlhorn.split.mountable_polys  = [];
m.environment.decompositon.convex.hertel_mehlhorn.split_needed = [];
m.environment.decompositon.convex.keil_snoeyink.polys = [];
m.environment.decompositon.convex.keil_snoeyink.mountable_edges = [];
m.environment.decompositon.convex.keil_snoeyink.unmountable.points = [];
m.environment.decompositon.convex.keil_snoeyink.split.polys = [];
m.environment.decompositon.convex.keil_snoeyink.split.mountable_edges  = [];
m.environment.decompositon.convex.keil_snoeyink.split.mountable_polys  = [];
m.environment.decompositon.convex.keil_snoeyink.split_needed = [];
m.environment.decompositon.triangular.types = {'ear_clipping', 'opt_length', 'monotone'};
m.environment.decompositon.triangular.ear_clipping.polys = [];
m.environment.decompositon.triangular.ear_clipping.mountable_edges = [];
m.environment.decompositon.triangular.ear_clipping.unmountable.points = [];
m.environment.decompositon.triangular.opt_length.polys = [];
m.environment.decompositon.triangular.opt_length.mountable_edges = [];
m.environment.decompositon.triangular.opt_length.unmountable.points = [];
m.environment.decompositon.triangular.monotone.polys = [];
m.environment.decompositon.triangular.monotone.mountable_edges = [];
m.environment.decompositon.triangular.monotone.unmountable.points = [];
m.environment.decompositon.triangular.delauny.polys = [];
m.environment.decompositon.triangular.delauny.mountable_edges = [];
m.environment.decompositon.triangular.delauny.unmountable.points = [];

%% generates struct in which all common model variables are stored
% Just a hint to the cplex values
%pc.model.cplex.enable = false; % creation of cplex Model matrices
%%
%% TODO: add dirdist_comb
model_types = {'ws', 'wss', 'it'};
m.model.filetypes = {'obj', 'st', 'bounds', 'bin', 'general'}; % types of tmp files
m.model.header = []; % user defined header of comments to file e.g. \Problem name: xyz
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
        m.model.types.(modname) = modname;
        m.model.(modname).id = 0;
        m.model.(modname).tag = tag;
        m.model.(modname).enable = false;
        m.model.(modname).quality.min = 0;
        m.model.(modname).quality.max = 1;
        m.model.(modname).quality.reject = 0;
        for mtq = model_types            
        m.model.(modname).quality.(mtq{1}).name = [];
        m.model.(modname).quality.(mtq{1}).param = 1;
        end          
        m.model.(modname).file.open = false;
        for modft = m.model.filetypes
        modft = modft{1};
        m.model.(modname).(modft).filename = {}; % cell array of files to be combined
        m.model.(modname).(modft).fid = []; % fids of files
        m.model.(modname).(modft).enable = true; % fids of files
        end
    end
end

%% generates struct in which all common problem variables are stored
m.problem.W = []; % [5,n] matrix where every point is defined by [x;y;q;w;k] q=min quality, w=weight
m.problem.wp_sc_idx = []; % {num_positions} with max [num_comb, 1] arrays with indices of sensor combinations that sees the workspace points
m.problem.wp_s_idx = []; % {num_positions} with max [num_sensors, 1] arrays with indices of sensor combinations that sees the workspace points
% pc.problem.wp_q_sin = {}; % {num_positions} cell array with qualities of sc that are in wp_sc_idx
% pc.problem.wp_q_dist = []; % [num_positions num_sensor] array with distances between sensors and workspace points
% pc.problem.wp_q_d1d2sin = []; % [num_positions num_sensor] array with distances between sensors and workspace points
% pc.problem.wp_q_sum = []; % [num_positions 1] array with sum of qualities for every point
% [4,n] matrix where every point is defined by [x;y;phi;k] k=sensor type
% the sensor fov ranges from phi to phi+pc.sensors.fov
m.problem.S = [];
m.problem.xt_ij = []; % visibility matrix [num_sensor_positions; num_workspace_positions]
m.problem.ct = []; % cost of sensor type t
m.problem.t_sum = []; % number of different sensor types
m.problem.St_i = []; % sensor choice matrix has the form st_i = [s1_1 ... s1_n s2_1 ... sn_n];
m.problem.k = [];  % [num_positions 1] vector that holds the coverage neede in each point
m.problem.q_dir = []; % [num_positions 1] vector that holds the directional coverage values needed at each point
m.problem.r_j = [];
% holds all visibility polygons
m.problem.V = {};
m.problem.sc_obj_mult = 0; % multiplier that is appendend to each sc variable
% pc.problem.sc_ij = []; % true for every sensor sensor combination that has a wp in their common fov
m.problem.sc_idx = []; % [n 2] array with all relevant two combinations of sensors sorted
% pc.problem.sc_ind = []; % [n 1] array with linear indices of sc_idx for a [num_sensors num_sensors] matrix
% pc.problem.sc_wp_idx = {}; % [num_comb 1] cell array with indices of workspace points that are in fov of sensor pair
% pc.problem.sp_idx = []; % cell array with indices of pc.problem.S that have the same x,y coordinates
m.problem.sp_ij = []; % columns=sensor_ids, rows=overlappings in fov
m.problem.q_sin = {}; % [num_comb 1] cell array with q_sin quality values for s1,s2 combinations of workspace points in sc_wp_idx
% pc.problem.q_dsub_scale = []; % holds the objective scale of the directional sub values
m.problem.num_sensors = [];
m.problem.num_positions = [];
m.problem.num_comb = [];
m.problem.quality.distance.min = 0;

m.model.directional_sub.quality.min = 0;

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
        m.quality.types.(qname) = qname;
        m.quality.(qname).name = name;
        m.quality.(qname).type = name;
        m.quality.(qname).tag = tag;
        m.quality.(qname).fct = eval(['@quality.' mt '.' name ]);
        m.quality.(qname).val = [];
        m.quality.(qname).valbw = [];
    end
end
% selected quality that is applied
m.quality.selected = [];

%% generates the envelope to store the sensorspace data
m.sensorspace.number_of_angles_per_position = 0;
m.sensorspace.angles_sampling_technique = m.common.sampling_techniques.uniform;
% only for random sampling
% (1) pre = one random sampling before the positions are calculated
% (2) within = sample new random angles for every sampled position
m.sensorspace.angles_sampling_occurences = struct('pre', 1, 'within', 2);
m.sensorspace.angles_sampling_occurence = m.sensorspace.angles_sampling_occurences.pre;
% minimum distance between two angles that is allowed
m.sensorspace.min_angle_distance = 0; % rad
m.sensorspace.min_position_distance = 100; % mm
m.sensorspace.max_position_distance = 300; % mm
m.sensorspace.uniform_position_distance = 100; % mm
m.sensorspace.uniform_angle_distance = deg2rad(9); % rad
m.sensorspace.use_overhead_positions = false;
m.sensorspace.position_sampling_technique = m.common.sampling_techniques.uniform; % random, uniform
m.sensorspace.seed = 0;
% min positions that have to be visible from each sensor in order to keep it in the visibility
% matrix
m.sensorspace.min_visible_positions = 1; 
% sensor has to see at least an area of 1m2
m.sensorspace.min_visible_area = 100000;
% diameter below polygon parts are considered to be spikes
m.sensorspace.spike_distance = 100; % 10 cm

%% generates the envelope to store the sensor data
m.sensors.fov = 45; % in degree
m.sensors.angle = deg2rad(m.sensors.fov); % the radian rep of fov
m.sensors.distance.max = 10000; % in mm
m.sensors.distance.min = 0; % in mm
% pc.sensors.quality.distance.max = 0.5; % on a distance of 50% of the sensors the quality is best
% pc.sensors.quality.distance.scale = 0.5; % max influence of distance quality
m.sensors.aoa_error = deg2rad(8); % the angular error that is used to calculate quality constraints
% pc.sensors.dist_error =  % do I need it?

%% generates the envelope to store the workspace data
m.workspace.number_of_positions = 100;
m.workspace.min_position_distance = 300;
m.workspace.max_position_distance = 300;
m.workspace.seed = 0;
m.workspace.grid_position_distance = 200;
m.workspace.sampling_technique = m.common.sampling_techniques.grid; % random, grid
m.workspace.x_axis_grid_distance = 100;
m.workspace.y_axis_grid_distance = 100;
m.workspace.wall_distance = 100;
% pc.workspace.quality.min = 0.6; % [0 .. 1] min quality
% pc.workspace.quality_technique = pc.common.sampling_techniques.uniform;
% pc.workspace.priority = 1; %uniform priority
% pc.workspace.priority_technique = pc.common.sampling_techniques.uniform;
m.workspace.coverage = 2; % uniform coverage
m.workspace.coverage_technique = m.common.sampling_techniques.uniform;


%% progress, has to be defined last

m.progress.environment.load = false;
m.progress.environment.combine = false;

m.progress.heuristic.cutoffs = false;
m.progress.heuristic.placement = false;

m.progress.model.init = false;
for type = fieldnames(m.model.types)'
    type = type{1};
    m.progress.model.(type) = false;
end
m.progress.sensorspace.sensorcomb = false;
m.progress.sensorspace.sameplace = false;
m.progress.sensorspace.positions = false;
m.progress.sensorspace.visibility = false;
m.progress.workspace.positions = false;

for type = fieldnames(m.quality.types)'
    type = type{1};
    m.progress.quality.(type) = false;
end
