function environment = combine(environment)
%%
% caluclates the combined environment and all information about edges
bpolyclip_options = Configurations.Bpolyclip.combine(Configurations.Bpolyclip.environment);

poly_wo_mountables = bpolyclip(environment.boundary.ring, environment.mountable, 0, bpolyclip_options);
if ~iscell(poly_wo_mountables)
    poly_wo_mountables = {poly_wo_mountables};
end
%%
bpolyclip_batch_options = Configurations.Bpolyclip.combine(Configurations.Bpolyclip.environment, true);
if ~isempty(environment.obstacles)
    %%
    % There are two cases for obstacles, they can either be partially or fully embedded in the outer
    % walls (windows, doors) or be compleatly inside the room (plants, cupboards).
    % Since we are only interessted in the ones that have min one point inside the polygon, we can test
    % for inpolygon before calculating the cuts
    num_obstacles = numel(environment.obstacles);
    obstacles_inside = false(1, num_obstacles);
    for idp = 1:num_obstacles
        [in, on] = binpolygon(environment.obstacles{idp}{1}, poly_wo_mountables, 1);
        obstacles_inside(idp) = any(in&~on);
    end
    %%%
    poly_wo_obstacles = bpolyclip_batch([poly_wo_mountables, environment.obstacles], 0, 1:num_obstacles+1, bpolyclip_batch_options);
    
    if numel(poly_wo_obstacles{1}) > 1
        %%
        warning('more than one poygon while combining, using greatest');
        area = cellfun(@mb.polygonArea, poly_wo_obstacles{1});
        [~, id_max] = max(area);
        poly_wo_obstacles = poly_wo_obstacles{1}{id_max};
    else
        environment.combined = poly_wo_obstacles{1};
    end
    
    %     environment.unmountable.edges = cellfun(@(pts) true(1, size(pts,2)), poly_wo_obstacles, 'uniformoutput', false);
    %     environment.unmountable.points = cellfun(@(pts) true(1, size(pts,2)), poly_wo_obstacles, 'uniformoutput', false);
    
else
    %%
    environment.combined = poly_wo_mountables;
    %     environment.combined = poly_wo_mountables{1};
    %     environment.unmountable.edges = cellfun(@(pts) true(1, size(pts,2)), poly_wo_mountables, 'uniformoutput', false);
    %     environment.unmountable.points = cellfun(@(pts) true(1, size(pts,2)), poly_wo_mountables, 'uniformoutput', false);
end

environment.combined = mb.mergePoints(environment.combined, 10);
%% remove spikes
environment.combined = bpolyclip(environment.combined, environment.combined, 1, true, 10, 1);
environment.combined = environment.combined{1};

if ~(iscell(environment.combined))
    environment.combined = {environment.combined};
end