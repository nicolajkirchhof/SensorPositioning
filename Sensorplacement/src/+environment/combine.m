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
    %%
    poly_wo_obstacles = bpolyclip_batch([poly_wo_mountables, environment.obstacles], 0, 1:num_obstacles+1, bpolyclip_batch_options);
    %%
    if iscell(poly_wo_obstacles{1}) && numel(poly_wo_obstacles{1}) > 1
        %%
        warning('more than one poygon while combining, using greatest');
        area = cellfun(@mb.polygonArea, poly_wo_obstacles{1});
        [~, id_max] = max(area);
        poly_wo_obstacles = poly_wo_obstacles{1}{id_max};
        environment.combined = poly_wo_obstacles;
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

    %% Redo environment to add points that are on obstacles
    %%% Test obstacle point integration
%     environment.boundary.ring = environment.boundary.ring_orig;
%     boundary_vpoly = mb.boost2visilibity(environment.boundary.ring);
%         boundary_edges = [combined_vpoly, circshift(combined_vpoly, -1, 1)];

    combined_vpoly = mb.boost2visilibity(environment.combined);
    combined_edges = cellfun(@(x) [x, circshift(x, -1, 1)], combined_vpoly, 'uniformoutput', false);
    obstacle_vpolys = cellfun(@(x)mb.boost2visilibity(x{1}), environment.obstacles, 'uniformoutput', false);
    obstacle_edges = cellfun(@(x) [x, circshift(x, -1, 1)], obstacle_vpolys,  'uniformoutput', false);
    %%    
    boundary_edges = combined_edges{1};
    for id_poly = 1:numel(obstacle_edges)
        %%
        edges = obstacle_edges{id_poly};
        for id_edge =  1:size(edges, 1)
            %%
            xings = intersectEdges(edges(id_edge,:), boundary_edges);
            flt_xing = ~isnan(xings(:,1)) & ~isinf(xings(:,1));
            %%
            if any(flt_xing)
                % every polygon must have two intersections
                id_xings = find(flt_xing);
                %%
                for idx = 1:numel(id_xings)
                    id_xing = id_xings(idx);
                    write_log('id_poly %d  id_edge %d id_xing %d\n', id_poly, id_edge, id_xing);
                    if edgeLength([ boundary_edges(id_xing, 1:2), xings(id_xing, :) ]) > 10 && ...
                        edgeLength([ xings(id_xing, :), boundary_edges(id_xing, 3:4) ]) > 10
                    boundary_edges = [boundary_edges(1:id_xing-1, :);
                        [ boundary_edges(id_xing, 1:2), xings(id_xing, :) ];
                        [ xings(id_xing, :), boundary_edges(id_xing, 3:4) ];
                        boundary_edges(id_xing+1:end, :)];
                    else 
                        write_log('Edge NOT added\n');
                    end
                end
                %             fprintf(1, '%d %d\n', id_poly, id_edge);
            end
        end
    end
    %% CREATE EDGE LOOKUP
    combined_edges{1} = boundary_edges;
    combined_pt_mid = cellfun(@(x) int64(bsxfun(@plus, x(:,1:2), (-x(:,1:2)+x(:,3:4))*.5))', combined_edges, 'uniformoutput', false);
    
    placeable_edges = cell(size(combined_pt_mid));
    %%
    for id_ply = 1:numel(combined_pt_mid)
       is_in_on_obst = cellfun(@(x) binpolygon(combined_pt_mid{id_ply}, x, 1), environment.obstacles, 'uniformoutput', false);
       placeable_edges{id_ply} = ~any(cell2mat(is_in_on_obst'), 1);
       %%
    end
    
    environment.combined_edges = combined_edges;
    environment.placable_edges = placeable_edges;

