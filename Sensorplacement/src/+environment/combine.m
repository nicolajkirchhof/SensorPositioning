function pc = combine(pc)
%%
% caluclates the combined environment and all information about edges
poly_wo_mountables = bpolyclip(pc.environment.walls.ring, pc.environment.mountable.poly, 0, pc.common.bpolyclip_options);
if ~iscell(poly_wo_mountables)
    poly_wo_mountables = {poly_wo_mountables};
end
%%%
if ~isempty(pc.environment.obstacles.poly)
    % There are two cases for obstacles, they can either be partially or fully embedded in the outer
    % walls (windows, doors) or be compleatly inside the room (plants, cupboards).
    % Since we are only interessted in the ones that have min one point inside the polygon, we can test
    % for inpolygon before calculating the cuts
    num_obstacles = numel(pc.environment.obstacles.poly);
    obstacles_inside = false(1, num_obstacles);
    for idp = 1:num_obstacles
        [in, on] = binpolygon(pc.environment.obstacles.poly{idp}{1}, poly_wo_mountables, pc.common.grid_limit);
        obstacles_inside(idp) = any(in&~on);
    end
    %%%
    poly_wo_obstacles = bpolyclip_batch([poly_wo_mountables, pc.environment.obstacles.poly], 0, 1:num_obstacles+1, pc.common.bpolyclip_batch_options);
    
    pc.environment.combined.poly = poly_wo_obstacles{1};
%     pc.environment.unmountable.edges = cellfun(@(pts) true(1, size(pts,2)), poly_wo_obstacles, 'uniformoutput', false);
%     pc.environment.unmountable.points = cellfun(@(pts) true(1, size(pts,2)), poly_wo_obstacles, 'uniformoutput', false);
    
else
    %%
    pc.environment.combined.poly = poly_wo_mountables{1};
%     pc.environment.unmountable.edges = cellfun(@(pts) true(1, size(pts,2)), poly_wo_mountables, 'uniformoutput', false);
%     pc.environment.unmountable.points = cellfun(@(pts) true(1, size(pts,2)), poly_wo_mountables, 'uniformoutput', false);
end
