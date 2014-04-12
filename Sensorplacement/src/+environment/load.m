function pc = load(pc)

if ~exist(pc.environment.file, 'file')
    error('file not declared or found');
    return;
end

point_idx = strfind(pc.environment.file, '.');
if strcmpi(pc.environment.file(point_idx(end)+1:end), 'mat')
    poly = load(pc.environment.file);
    pc.environment.combined.poly = poly.bpoly;
    pc.environment.walls.ring = poly.bpoly{1};
elseif strcmpi(pc.environment.file(point_idx(end)+1:end), 'environment')
%       error('obsolete');
%     %%
      poly_comb = mb.visilibity2boost(load_environment_file(pc.environment.file));
      pc.environment.walls.ring = poly_comb{1};
      pc.environment.mountable.poly = poly_comb(2:end);
      pc.environment.combined.poly = poly_comb;
%     % convert to boost representation
%     for idp = 1:numel(pc.environment.poly.visilibity)
%         pc.environment.poly.boost{idp} = [pc.environment.poly.visilibity{idp}', pc.environment.poly.visilibity{idp}(end,:)'];
%     end
%     %%
%     pc = calculate_workspace_representation(pc);
elseif strcmpi(pc.environment.file(point_idx(end)+1:end), 'dxf')
    %%
    [c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(pc.environment.file);
    
    object_description = c_Poly(:,2);
    object_bpoly_int = cellfun(@(x) int64(x'), c_Poly(:,1), 'UniformOutput', false);
    
    flt_mountable_objects = strcmpi('mountable', object_description);
    flt_obstacle_objects = strcmpi('obstacle', object_description);
    flt_occupied_objects = strcmpi('occupied', object_description);
    flt_wall_objects = strcmpi('wall', object_description);
    
    % options  correct, remove spikes , progress bar, remove touch
    b_b_opt = {1, pc.environment.spike_distance, pc.common.verbose, pc.common.grid_limit};
    % bpolyclip_batch returns list of multi-polygons
    if sum(flt_mountable_objects) > 1
        pc.environment.mountable.poly = bpolyclip_batch(object_bpoly_int(flt_mountable_objects), 3, {1:sum(flt_mountable_objects)}, b_b_opt{:});
        pc.environment.mountable.poly = pc.environment.mountable.poly{1};
    elseif sum(flt_mountable_objects) == 1
        pc.environment.mountable.poly = object_bpoly_int(flt_mountable_objects);
    end
    if any(flt_obstacle_objects) 
    pc.environment.obstacles.poly = bpolyclip_batch(object_bpoly_int(flt_obstacle_objects), 3, {1:sum(flt_obstacle_objects)}, b_b_opt{:});
    pc.environment.obstacles.poly = pc.environment.obstacles.poly{1};
    end
    if any(flt_occupied_objects)
    pc.environment.occupied.poly  = bpolyclip_batch(object_bpoly_int(flt_occupied_objects), 3, {1:sum(flt_occupied_objects)}, b_b_opt{:});
    pc.environment.occupied.poly  = pc.environment.occupied.poly{1};
    end
    pc.environment.walls.poly      = bpolyclip_batch(object_bpoly_int(flt_wall_objects), 3, {1:sum(flt_wall_objects)}, b_b_opt{:});
    pc.environment.walls.poly     = pc.environment.walls.poly{1};
    
    if numel(pc.environment.walls.poly{1}) ~= 2
        error('wall could not be converted into contour');
    end
    pc.environment.walls.ring = pc.environment.walls.poly{1}{2}(:,end:-1:1);
else
    error('file extension unknown');
end

% save progress
pc.progress.environment.load = true;

