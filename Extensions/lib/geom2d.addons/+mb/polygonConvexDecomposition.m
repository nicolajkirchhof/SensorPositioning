function [rings, cutinfo, pcd] = polygonConvexDecomposition(poly, verbose)
% REWRITE ACCORDING TO PAPER
if nargin < 2; verbose = false; end
% if ~iscell(bpoly)||numel(mb.flattenPolygon(bpoly))==1
%     rings = bpoly;
%     cutinfo = [];
%     pcd = [];
%     return;
% end
%%
bpoly = mb.correctPolygon(poly);
clearvars -except gpoly bpoly verbose
gpoly = mb.boost2visilibity(bpoly);
if verbose, cla, hold on, drawPolygon(gpoly), end;
gpoly_ringsizes = cellfun(@(x) size(x,1), gpoly);
gpoly_ringnum = numel(gpoly);

% get cw orientation of all rings
orientation = cellfun(@polygonIsCounterClockwise, gpoly, 'uniformoutput', false);
% outer ring must be ccw in order to get interior angles, holes must be cw
% in order to get exterior angles
if orientation{1} < 0
    gpoly{1} = flipud(gpoly{1});
end
for idring = 2:gpoly_ringnum
    if orientation{idring} > 0
        gpoly{idring} = flipud(gpoly{idring});
    end
end
%
% calculate all convex angles of holes cw orientation required
% angles = mb.polygonAngles(bpoly);
[normal_angles, angles] = polygonNormalAngles(gpoly);

flt_convex_angles = cellfun(@(x) x>pi, angles, 'uniformoutput', false);
% special case, polygon has no holes and is already convex
if numel(flt_convex_angles) == 1 && all(flt_convex_angles{1} == 0)
    rings = bpoly;
    cutinfo = [];
    pcd  = [];
    return;
end

% E_r contains polylines consisting of two segments
E_r = {};
for idring = 1:numel(gpoly)
    ids_ringpoints = find(flt_convex_angles{idring});
    for idpt = ids_ringpoints'
        %%
        % assign points, normal angles and rays
        pl = createReferingPolyline();
        % shift ring to start ad idpt
        ring_size = size(gpoly{idring}, 1);
        % transforms index to [0 ringsize] calcs circ and restores original
        % index
        pl.point_ids = (mod(idpt-2:idpt, ring_size)+1)';
        pl.ring_ids = repmat(idring,3,1);
        pl.points = gpoly{idring}(pl.point_ids,:);
        if verbose; drawPoint(pl.points(2,:), 'og'); end
        pl.normal_angles = normal_angles{idring}(pl.point_ids,:);
        E_r{end+1} = pl; %#ok<AGROW>
    end
end
% P_r = reflex_points
% P_r = cellfun(@(x, flt) x(flt, :), gpoly, flt_convex_angles, 'uniformoutput', false);
% Phi_r = reflex_normal_angles
% Phi_rn = cellfun(@(x, flt) x(flt, :), normal_angles, flt_convex_angles, 'uniformoutput', false);

% E_c = connecting edges
E_c = {};
%%%
idreflex = 1;
%%%
while idreflex <= numel(E_r)
    %     ray = createRay(P_r(idreflex, :), Phi_rn(idreflex, :));
    ray = createRay(E_r{idreflex}.points(2,:), E_r{idreflex}.normal_angles(2));
    % intersection points with all rings
    [xing_points, xing_point_ids] = cellfun(@(ring) intersectLinePolygon(ray, ring), gpoly, 'uniformoutput', false);
    [xing_point_dist] = cellfun(@(pt) linePosition(pt, ray), xing_points, 'uniformoutput', false);
    %     [xing_point_dist, xing_point_dist_ids] = cellfun(@(pos) min(pos(pos>=1)), Pos_int, 'uniformoutput', false);
    %%% get the index of the nearest ring
    %     nearest_ring_dist_mat = inf(size(xing_point_dist));
    %%
    xing_min_dist = inf;
    for idring = 1:numel(gpoly_ringsizes)
        xing_flt = xing_point_dist{idring} >= 1;
        [xing_new_dist, xing_new_dist_idx] = min(xing_point_dist{idring}(xing_flt));
        if xing_new_dist < xing_min_dist
            xing_points{idring} = xing_points{idring}(xing_flt, :);
            xing_point = xing_points{idring}(xing_new_dist_idx, :);
            xing_ring_id = idring;
            xing_point_ids{idring} = xing_point_ids{idring}(xing_flt);
            xing_point_id = xing_point_ids{idring}(xing_new_dist_idx);
            %         if ~isempty(xing_point_dist{idring})
            %             nearest_ring_dist_mat(idring) = xing_point_dist{idring};
            %         end
        end
    end
    %     [~, xing_ring_id] = min(nearest_ring_dist_mat);
    %     xing_point_id = xing_point_dist_ids{xing_ring_id};
    %     xing_point = xing_points{xing_ring_id}(xing_point_id, :);
    %% calculate point id with offset on line
    xing_point_next_id = mod(xing_point_id, gpoly_ringsizes(xing_ring_id))+1;
    line = createLine(gpoly{xing_ring_id}(xing_point_id, :), gpoly{xing_ring_id}(xing_point_next_id, :));
    linepos = linePosition(xing_point, line);
    xing_point_exact_id = xing_point_id + linepos;
    %% use refering polyline as refering segment
    s_cut = createReferingPolyline();
    s_cut.points = [E_r{idreflex}.points(2,:); xing_point];
    s_cut.point_ids = [E_r{idreflex}.point_ids(2); xing_point_exact_id];
    s_cut.ring_ids = [E_r{idreflex}.ring_ids(2); xing_ring_id];
    s_cut.edges = createEdge(s_cut.points(1,:), s_cut.points(2,:));
    if verbose; s_cut.handle = drawEdge(s_cut.edges, 'color', 'g');  end
    %% test if ray intersects with one edge in Ec
    segment_xing = [];
    segment_xing_id = [];
    segment_xing_dist = inf;
    for ids = 1:numel(E_c)
        P = intersectEdges(s_cut.edges, E_c{ids}.edges);
        %% first two handle non intersections last one assures that intersections does not happen
        % at one of the endpoints
        if ~all(isnan(P))&&~all(isinf(P))&&all(distancePoints(P, s_cut.points)>1)
            s_xing = createReferingPolyline();
            s_xing.points = [s_cut.points(1,:); E_c{ids}.points(1,:)];
            s_xing.ring_ids = [s_cut.ring_ids(1); E_c{ids}.ring_ids(1)];
            s_xing.point_ids = [s_cut.point_ids(1); E_c{ids}.point_ids(1)];
            s_xing.edges = createEdge(s_xing.points(1,:), s_xing.points(2,:));
            if verbose; s_xing.handle = drawEdge(s_xing.edges, 'color', 'r'); delete(s_cut.handle);  end
            new_segment_length = edgeLength(s_xing.edges);
            if new_segment_length < segment_xing_dist
                segment_xing = s_xing;
                segment_xing_id = ids;
                segment_xing_dist = new_segment_length;
            end
        end
    end
    if ~isempty(segment_xing)
        %% ray intersects: remove intersecting edge from Ec(P_j, P_x) if it is not a merged edge
        % add new edge E(P_i, P_j) in Ec
        % check if angle E(P_j, P_i)/E(P_i, P_i+1) or angle E(P_i, P_j)/E(P_j,
        % P_j+1) is reflex and add to Er if so
        s_replace = E_c{segment_xing_id};
        segment_xing.is_merged_cut = true;
        
        % move to connection to one of the endpoints if is cut edge, else test if we have reflex
        % edge
        if s_replace.is_merged_cut
            E_c = [{segment_xing} E_c];
            idreflex = idreflex+1;
        else
            E_c{end+1} = segment_xing; %#ok<AGROW>
            if verbose; delete(s_replace.handle);  end
            E_c(segment_xing_id) = []; %#ok<AGROW>
            segments = {s_cut; s_replace};
            for ids = 0:1
                segments = circshift(segments, ids);
                s1 = segments{1};
                s2 = segments{2};
                % two candidates for next point on ring
                % the smaller of the inner and outer angles has to be checked
                ring_sz = gpoly_ringsizes(s2.ring_ids(1));
                s2p11_idx_cand = [mod(s2.point_ids(1)-2, ring_sz)+1; mod(s2.point_ids(1), ring_sz)+1];
                fun_angle_idx = @(idx) angle3Points(s1.points(1,:), s2.points(1,:), gpoly{s2.ring_ids(1)}(idx,:));
                fun_reverse_angle_idx = @(idx) angle3Points(gpoly{s2.ring_ids(1)}(idx,:), s2.points(1,:), s1.points(1,:));
                angle_cands = arrayfun(fun_angle_idx, s2p11_idx_cand);
                angle_reverse_cands = arrayfun(fun_reverse_angle_idx, s2p11_idx_cand);
                % find the min angle in both orientations and use the max to see where to cut
                [angle_cand_mins, angle_cand_mins_idx] = min([angle_cands(:), angle_reverse_cands(:)], [], 1);
                [angle_cand_min_max, angle_cand_min_max_id] = max(angle_cand_mins);
                if  angle_cand_min_max > pi
                    s2p11_idx = s2p11_idx_cand(angle_cand_mins_idx(angle_cand_min_max_id));
                    e_s1p1_s2p1_s2p11 = createReferingPolyline();
                    e_s1p1_s2p1_s2p11.points = [s1.points(1,:); s2.points(1,:); gpoly{s2.ring_ids(1)}(s2p11_idx,:) ];
                    e_s1p1_s2p1_s2p11.ring_ids = [s1.ring_ids(1,:); s2.ring_ids(1,:); s2.ring_ids(1,:)];
                    e_s1p1_s2p1_s2p11.point_ids = [s1.point_ids(1,:); s2.point_ids(1,:); s2p11_idx];
                    % polyline must be cw in order to get outer angles
                    if polygonIsCounterClockwise(e_s1p1_s2p1_s2p11.points) > 0
                        e_s1p1_s2p1_s2p11.points = flipud(e_s1p1_s2p1_s2p11.points);
                        e_s1p1_s2p1_s2p11.ring_ids = flipud(e_s1p1_s2p1_s2p11.ring_ids);
                        e_s1p1_s2p1_s2p11.point_ids = flipud(e_s1p1_s2p1_s2p11.point_ids);
                    end
                    e_s1p1_s2p1_s2p11.normal_angles = polygonNormalAngles(e_s1p1_s2p1_s2p11.points);
                    E_r{end+1} = e_s1p1_s2p1_s2p11; %#ok<AGROW>
                end
            end
        end
    else
        E_c{end+1} = s_cut; %#ok<AGROW>
    end
    
    %%
    
    
    %% CONTINUE HERE
    % intersect_points has structure {{intersection ring1_ray1 with ring 1, ring 2, ...}, ...}
    %     fun_intersect_ring = @(x) cellfun(@(ply) intersectRayPolygon(x, ply), gpoly, 'uniformoutput', false);
    %     intersect_points = cellfun(@(ring_rays) cellfun(fun_intersect_ring, ring_rays,'uniformoutput', false), rays_to_intersect, 'uniformoutput', false);
    %
    idreflex = idreflex+1;
end
%% return;
clearvars -except gpoly* bpoly verbose E_c
% Create graph from cut edges and gpoly edges
% following properties are used for that
% points = [2 2] start and endpoint of edge
% reference = [bool] is edge reference or not
% in_connections = [n 1] unique ids of in connected ids
% out_connections = [n 1] unique ids of out connected ids
% is_cut_edge = [bool] if it is a cutting edge
% unique_id = [int] unique id of edge

fun_create_graph_edge = @() struct(...
    'points', []...
    , 'reference', []...
    ...%     , 'in_connections', []...
    ...%     , 'out_connections', []...
    , 'is_cut_edge', []...
    , 'unique_id', []);
% unique_id = [int] unique id of edge

% E_c_reversed = E_c;
% for ide = 1:numel(E_c)
%     E_c_reversed{ide}.points = flipud(E_c_reversed{ide}.points);
%     E_c_reversed{ide}.ring_ids = flipud(E_c_reversed{ide}.ring_ids);
%     E_c_reversed{ide}.point_ids = flipud(E_c_reversed{ide}.point_ids);
%     E_c_reversed{ide}.unique_id = ide;
%     E_c{ide}.unique_id = ide;
% end
% graph_edges = [E_c, E_c_reversed];

% build three lookup matrices, one that hold the
% ring ids | point ids | px | py
% and a second, third one that holds the incomming and outgoing
% edge ids for every point

E_c_edges = cell(1, numel(E_c)*2);
for ide = 1:numel(E_c)
    e_forward = fun_create_graph_edge();
    e_backward = fun_create_graph_edge();
    
    e_forward.points = E_c{ide}.points;
    e_forward.unique_id = ide*2-1;
    e_forward.is_cut_edge = true;
    e_forward.point_ids = E_c{ide}.point_ids;
    e_forward.ring_ids = E_c{ide}.ring_ids;
    
    e_backward.points = flipud(e_forward.points);
    e_backward.unique_id = ide*2;
    e_backward.is_cut_edge = true;
    e_backward.ring_ids = flipud(e_forward.ring_ids);
    e_backward.point_ids = flipud(e_forward.point_ids);
    
    e_forward.reference = e_backward.unique_id;
    e_backward.reference = e_forward.unique_id;
    
    E_c_edges{e_forward.unique_id} = e_forward;
    E_c_edges{e_backward.unique_id} = e_backward;
end

%%% create lookup tables with all edges
% [ring_id, point_id, E_c_idx, visited]
% E_c_in_lookup = cell2mat(cellfun(@(edge) [edge.ring_ids(2) edge.point_ids(2) edge.points(2,:) edge.unique_id], E_c_edges, 'uniformoutput', false)');
E_c_out_lookup = cell2mat(cellfun(@(edge) [edge.ring_ids(1) edge.point_ids(1) edge.points(1,:) edge.unique_id], E_c_edges, 'uniformoutput', false)');
gpoly_lookup = cell2mat(arrayfun(@(pts_sz, ring_id) [repmat(ring_id,pts_sz,1), (1:pts_sz)'], gpoly_ringsizes, 1:gpoly_ringnum ,'uniformoutput', false)');
gpoly_lookup(:,3:4) = cell2mat(gpoly');
gpoly_lookup(:,5) = inf;
[ring_ids] = unique(gpoly_lookup(:,1));

% edges_combined = [E_c_lookup; gpoly_lookup];
% poly_lookup_in = sortrows([E_c_in_lookup; gpoly_lookup]);
poly_lookup_out = sortrows([E_c_out_lookup; gpoly_lookup]);
%%% create indices lookups
edges_lookup = {};
% in_edges_lists = {};
out_edges_lists = {};
cnt = 0;
%%%
for idel = 1:size(poly_lookup_out, 1)
    if idel==1 || ~all(poly_lookup_out(idel-1, 1:2)==poly_lookup_out(idel,1:2))
        cnt = cnt +1;
        edges_lookup{cnt} = [poly_lookup_out(idel,1:4) cnt];  %#ok<AGROW>
    end
    %%
    %     indices_cand_in = poly_lookup_in(idel,5);
    indices_cand_out = poly_lookup_out(idel,5);
    if numel(out_edges_lists)<cnt
        %         in_edges_lists{cnt} = [];
        out_edges_lists{cnt} = []; %#ok<AGROW>
    end
    %     in_edges_lists{cnt} = [in_edges_lists{cnt} indices_cand_in(~isinf(indices_cand_in))];
    out_edges_lists{cnt} = [out_edges_lists{cnt} indices_cand_out(~isinf(indices_cand_out))];  %#ok<AGROW>
    
end
edges_lookup = cell2mat(edges_lookup');
%%%
graph_edges = E_c_edges;
last_uuid = numel(graph_edges);
%%%
for idring = ring_ids'
    %%
    ring_lookup = edges_lookup(edges_lookup(:,1)==idring, :);
    %     indices_ring = out_edges_lists(edges_lookup(:,1)==idring);
    %     for idedge = 1:size(ring_edges, 1)
    num_points = size(ring_lookup, 1);
    point_lookup = ring_lookup(:,3:4);
    point_indices = ring_lookup(:,5);
    
    %%
    forward_edges = [point_lookup, circshift(point_lookup, -1)];
    forward_indices = [point_indices, circshift(point_indices, -1)];
    new_indices = [(last_uuid+1:last_uuid+num_points)', (last_uuid+num_points+1:last_uuid+2*num_points)'];
    last_uuid = last_uuid+2*num_points;
    %     connecting_indices = [circshift(new_indices(:,1),1), circshift(new_indices(:,1), -1), circshift(new_indices(:,2),-1), circshift(new_indices(:,2), 1)];
    %     connecting_edges = {indices_ring', circshift(indices_ring', -1)};
    %% create edges on ring
    for idpt = 1:num_points
        forward_edge = fun_create_graph_edge();
        backward_edge = fun_create_graph_edge();
        forward_edge.points = [forward_edges(idpt,1:2); forward_edges(idpt,3:4)];
        backward_edge.points = [forward_edges(idpt,3:4); forward_edges(idpt,1:2)];
        forward_edge.is_cut_edge = false;
        backward_edge.is_cut_edge = false;
        forward_edge.unique_id = new_indices(idpt, 1);
        backward_edge.unique_id = new_indices(idpt, 2);
        forward_edge.reference = backward_edge.unique_id;
        backward_edge.reference = forward_edge.unique_id;
        graph_edges{forward_edge.unique_id} = forward_edge;
        graph_edges{backward_edge.unique_id} = backward_edge;
        %% add new edges to in and out eges lists
        %         in_edges_lists{forward_indices(idpt,1)}(end+1) = backward_edge.unique_id;
        out_edges_lists{forward_indices(idpt,2)}(end+1) = backward_edge.unique_id; %#ok<AGROW>
        %         in_edges_lists{forward_indices(idpt,2)}(end+1) = forward_edge.unique_id;
        out_edges_lists{forward_indices(idpt,1)}(end+1) = forward_edge.unique_id; %#ok<AGROW>
    end
end
% return;
%% TODO Remove only points that are on the gpoly boudary
% [~, edges_ids_unique_sorted] =  unique(edges_combined(:,1:2), 'rows', 'sorted');
% edges_lookup = edges_combined(edges_ids_unique_sorted, :);
clearvars -except gpoly* bpoly verbose E_c graph_edges edges_lookup out_edges_lists in_edges_lists
graph_edges_remaining = graph_edges;
pcd = {};
% for idec = 1:numel(graph_edges);
all_removed = false;
next_start = 1;
while ~all_removed
    while next_start<=numel(graph_edges_remaining) && isempty(graph_edges_remaining{next_start});
        next_start = next_start + 1;
    end
    polyline = graph_edges_remaining(next_start);
    graph_edges_remaining{next_start} = [];
    closed = false;
    if verbose;
        %%
        %         h_poly_edges = [];
        h_cut_edges = [];
        %         cla; drawPolygon(gpoly); hold on;
        fun_createEdge = @(pts) createEdge(pts(1,:), pts(2,:));
        fun_drawEdge = @(e) drawEdge(fun_createEdge(e.points), 'color', 'b');
        flt_nonempty = cellfun(@(e) ~isempty(e), graph_edges_remaining);
        cla; hold on; cellfun(fun_drawEdge, graph_edges_remaining(flt_nonempty));
        h_edges = drawEdge(fun_createEdge(polyline{end}.points), 'color', 'm');
        
    end
    %%
    while (~closed)
        % get candidates for next point
        point_out = polyline{end}.points(2,:);
        %         point_out_id = find(edges_lookup(:,3)==point_out(1) & edges_lookup(:,4)==point_out(2));
        point_out_flt = edges_lookup(:,3)==point_out(1) & edges_lookup(:,4)==point_out(2);
        next_edge_candidates = out_edges_lists{point_out_flt};
        
        num_next_edge_candidates = numel(next_edge_candidates);
        flt_candidates = false(1, num_next_edge_candidates);
        for idnec = 1:num_next_edge_candidates
            e_id = next_edge_candidates(idnec);
            if ~isempty(graph_edges_remaining{e_id})
                flt_candidates(idnec) = graph_edges_remaining{e_id}.reference ~= polyline{end}.unique_id;
            end
        end
        %         idx_next = nan;
        lowest_angle = inf;
        %%%             for idce = find(cut_connections)
        for idx_next_cand = next_edge_candidates(flt_candidates)
            % plot connecting edges
            %% determine edge with lowest angle
            p_prev = polyline{end}.points(1,:);
            p_curr = polyline{end}.points(2,:);
            %             idx_next_cand = next_edge_candidates(idce);
            if verbose
                h_cut_edges(end+1) = drawEdge(fun_createEdge(graph_edges_remaining{idx_next_cand}.points), 'color', 'c'); %#ok<AGROW>
                
            end
            p_next = graph_edges_remaining{idx_next_cand}.points(2,:);
            ccw = isCounterClockwise(p_prev, p_curr, p_next);
            if ccw < 0
                angle = angle3Points(p_prev, p_curr, p_next);
                if angle < lowest_angle
                    lowest_angle = angle;
                    lowest_idx = idx_next_cand;
                end
            end
        end
        idx_next = lowest_idx;
        polyline{end+1} = graph_edges_remaining{idx_next}; %#ok<AGROW>
        if ~graph_edges_remaining{idx_next}.is_cut_edge
            graph_edges_remaining{graph_edges_remaining{idx_next}.reference} = [];
        end
        if verbose
            h_edges(end+1) = drawEdge(fun_createEdge(polyline{end}.points), 'color', 'm'); %#ok<AGROW>
            
        end
        graph_edges_remaining{idx_next} = [];
        if all(polyline{end}.points(2,:) == polyline{1}.points(1,:))
            closed = true;
            pcd{end+1} = polyline; %#ok<AGROW>
            all_removed = all(cellfun(@(x) isempty(x), graph_edges_remaining));
            if verbose
                %                 
                %                 set(h_edges, 'color', 'w');
                set(h_cut_edges, 'color', 'b');
                %                 delete(h_poly_edges);
                
            end
        end
        %%
    end
end
%% create polygons from pcd
fun_pointextract = @(edgelist) unique(cell2mat(cellfun(@(edge) edge.points, edgelist, 'uniformoutput', false)'), 'rows', 'stable');
fun_cutinfoextract = @(edgelist) cellfun(@(edge) edge.is_cut_edge, edgelist);
rings = cellfun(fun_pointextract, pcd, 'uniformoutput', false);
cutinfo = cellfun(fun_cutinfoextract, pcd, 'uniformoutput', false);
for idr = 1:numel(rings)
    % test if ring is ccw since it is convex, any three points can be used
    if isCounterClockwise(rings{idr}(1,:), rings{idr}(2,:), rings{idr}(3,:)) < 0
        % keep first point stable in order to avoid edge association changes
        rings{idr} = [rings{idr}(1,:);flipud(rings{idr}(2:end,:))];
        cutinfo{idr} = fliplr(cutinfo{idr});
    end
end
rings = cellfun(@mb.visilibity2boost, rings, 'uniformoutput', false);


return;

%% TEST
%% Testing
clear variables;
format long;
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe';
fun_solve = @(filename) Optimization.Discrete.Solver.cplex.run(filename, cplex);
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
environment = Environment.combine(environment);
poly = Environment.Decompose.simplify(environment.combined{1}, 1);
[rings, cutinfo, pcd] = mb.polygonConvexDecomposition(poly, true);


%
% %% plot normals
% length = 100;
% normals = cellfun(@(x)createEdge(double(x), repmat(length, size(x,1),1)), E_r, 'uniformoutput', false);
% figure, hold on,
% drawPolygon(gpoly);
% cellfun(@drawEdge, normals);
% [x, ids] = mb.flattenPolygon(intersect_points);
% [points, ids] = cell2mat(mb.flattenPolygon(intersect_points)');
% edges = cell2mat(mb.flattenPolygon(intersect_edges)');
% drawPoint(points);
% drawEdge(edges);
