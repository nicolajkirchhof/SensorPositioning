function common = generic(in_name, wd)
%% GENERIC generic configuration of common variables
persistent name tag init workdir

if isempty(init)
    name = 'unnamed';
    tag = datestr(now,30);
    init = true;
    workdir = '../tmp/';
    if nargin > 0
        name = in_name;
    end
    if nargin > 1
        workdir = wd;
    end 
end

common.workdir = workdir;
if ~exist(common.workdir, 'dir')
    mkdir(common.workdir);
end

%%
common.tag = tag;
common.is_logging = true; 
common.verbose = true; % should additional output like progress bars be displayed
common.is_display = true; % should calculated properties be displayed on screen
common.debug = false; % additional debug infos, plots and more
common.check_polygons = true;
common.workmem = 5e8; % size of data to hold in ram before writing to tmpfile default 500MB
common.linesize = 300; % number of chars per line must be < 500
common.linecache = 100000; % number lines to cache before write
common.logname = [];

%% UNUSED
% common.sampling_techniques = struct('none', 0,'random', 1, 'grid', 2, 'uniform', 3, 'iterative', 4);
%Robustness constant
% common.epsilon = 1e-10; % 5mm
%Snap distance (distance within which an observer location will be snapped to the
%boundary before the visibility polygon is computed)
% common.snap_distance = 10;
% common.valid_poly_area = 10000; % min area for which polygon intersections are considered = 10cm2
% exactness of the created polylines
% common.polyline_verticies = 10;
% common.grid_limit = 1; % 1 mm
% common.spike_distance = 10; % 1 cm
% common.bpolyclip_batch_options = {common.check_polygons, common.spike_distance, common.grid_limit, common.verbose};
% common.bpolyclip_options = {common.check_polygons, common.spike_distance, common.grid_limit};

