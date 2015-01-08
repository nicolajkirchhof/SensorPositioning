function environment = load(filename, bpolyclip_options)
%% LOAD(filename, options) loads an environment based on the filename extension

environment = DataModels.environment;
environment.file = filename;
if nargin < 2
    bpolyclip_options = Configurations.Bpolyclip.environment;
%     bpolyclip_options.spike_distance = 10;
end
bpo = Configurations.Bpolyclip.combine(bpolyclip_options);


if ~exist(filename, 'file')
    error('file not declared or found');
    return;
end

point_idx = strfind(filename, '.');
if strcmpi(filename(point_idx(end)+1:end), 'mat')
    poly = load(filename);
    environment.combined = poly.bpoly;
    environment.boundary.ring = poly.bpoly{1};
elseif strcmpi(filename(point_idx(end)+1:end), 'environment')
%       error('obsolete');
%     %%
      poly_comb = mb.visilibity2boost(load_environment_file(filename));
      environment.boundary.ring = poly_comb{1};
      environment.mountable = poly_comb(2:end);
      environment.combined = poly_comb;
%     % convert to boost representation
%     for idp = 1:numel(environment.visilibity)
%         environment.boost{idp} = [environment.visilibity{idp}', environment.visilibity{idp}(end,:)'];
%     end
%     %%
%     pc = calculate_workspace_representation(pc);
elseif strcmpi(filename(point_idx(end)+1:end), 'dxf')
    %%
    [c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);
    
    object_description = c_Poly(:,2);
    object_bpoly_int = cellfun(@(x) int64(x'), c_Poly(:,1), 'UniformOutput', false);
    
    flt_mountable_objects = strcmpi('mountable', object_description);
    flt_obstacle_objects = strcmpi('obstacle', object_description);
    flt_occupied_objects = strcmpi('occupied', object_description);
    flt_wall_objects = strcmpi('wall', object_description);
    
    % bpolyclip_batch returns list of multi-polygons
    if sum(flt_mountable_objects) > 1
        environment.mountable = bpolyclip_batch(object_bpoly_int(flt_mountable_objects), 3, {1:sum(flt_mountable_objects)}, bpo{:});
        environment.mountable = environment.mountable{1};
    elseif sum(flt_mountable_objects) == 1
        environment.mountable = object_bpoly_int(flt_mountable_objects);
    end
    if any(flt_obstacle_objects) 
    environment.obstacles = bpolyclip_batch(object_bpoly_int(flt_obstacle_objects), 3, {1:sum(flt_obstacle_objects)}, bpo{:});
    environment.obstacles = environment.obstacles{1};
    end
    if any(flt_occupied_objects)
    environment.occupied  = bpolyclip_batch(object_bpoly_int(flt_occupied_objects), 3, {1:sum(flt_occupied_objects)}, bpo{:});
    environment.occupied  = environment.occupied{1};
    end
    environment.walls      = bpolyclip_batch(object_bpoly_int(flt_wall_objects), 3, {1:sum(flt_wall_objects)}, bpo{:});
    environment.walls     = environment.walls{1};
    
    if numel(environment.walls{1}) ~= 2
        warning('wall could not be converted into contour using second greatest size');
        sizes = cellfun(@(x) abs(mb.polygonArea(x)),  environment.walls{1});
        [~, id_sz] = max(sizes);
        sizes(id_sz) = 0;
        [~, id_sz] = max(sizes);
        environment.boundary.ring = environment.walls{1}{id_sz}(:,end:-1:1);
    else
        environment.boundary.ring = environment.walls{1}{2}(:,end:-1:1);
    end
    
else
    error('file extension unknown');
end

environment.boundary.ring = mb.closeRing(environment.boundary.ring);
environment.boundary.isplaceable = true(1, size(environment.boundary.ring, 2)-1);
% save progress
% progress.environment.load = true;
return;

%% TEST '.environment' load
filename = 'res/env/convex_polygons/sides4_nr0.environment';
environment = Environment.load(filename);
log_test(~isempty(environment), 'environment empty');
refring = [ 0, 3000, 3000, 0, 0 ; 0, 0, 3000, 3000, 0 ];
log_test(all(environment.boundary.ring(:) == refring(:)), 'Content test');
log_test(all(environment.boundary.isplaceable == true(1, size(refring, 2))), 'Isplaceable test');

%% TEST '.environment' load
filename = 'res\floorplans\reference\SimpleRectangle.dxf';
refring = [ 100, 4563, 4563, 100, 100 ; 417, 417, 4300, 4300, 417 ];
environment = Environment.load(filename);
log_test(~isempty(environment), 'environment empty');
log_test(strcmp(filename, environment.file), 'filename matches');
log_test(all(environment.boundary.ring(:) == refring(:)), 'Content test');
log_test(all(environment.boundary.isplaceable == true(1, size(refring, 2))), 'Isplaceable test');
