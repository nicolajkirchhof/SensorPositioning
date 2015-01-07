function [P_c] = convexPolygonCreation(vpoly, E_r, verbose)
% REWRITE ACCORDING TO PAPER
if nargin < 2; verbose = false; end
% if ~iscell(bpoly)||numel(mb.flattenPolygon(bpoly))==1
%     rings = bpoly;
%     cutinfo = [];
%     pcd = [];
%     return;
% end
%%
% import g2d.*;

while isempty(E_r)
    %%
    vpoly_edges = cellfun(@(x) [x(1:end, :), [x(2:end, :);x(1,:)]], vpoly, 'uniformoutput', false);
    
    for id_er = 1:numel(E_r)
       distance_polypoints = cellfun(@(x) distancePoints(E_r{id_er}.end, x), vpoly, 'uniformoutput', false);
       is_poly_point = any(cellfun(@(x) any(x <= 1), distance_polypoints));
       
       if ~is_poly_point
           %%
           distance_polyedges = cellfun(@(x) distancePointEdge(E_r{id_er}.end, x), vpoly_edges, 'uniformoutput', false);
           id_poly = cellfun(@(x) any(x <= 1), distance_polyedges);
           id_edge = find(distance_polyedges{id_poly} <= 1);
           vpoly{id_poly} = [vpoly{id_poly}(1:id_edge, :); E_r{id_er}.end; vpoly{id_poly}(id_edge+1:end, :)];
       end
    end
    
end
    vpoly_edges = cellfun(@(x) [x(1:end, :), [x(2:end, :);x(1,:)]], vpoly, 'uniformoutput', false);

return;
%% Tests
filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

% vpoly = c_Poly(:,1);
vpoly = cellfun(@(x) x(1:end-1, :)*100,  c_Poly(:,1), 'UniformOutput', false);
% vpoly{4} = circshift(vpoly{4}, -1, 1);
vpoly(2:end) = cellfun(@flipud, vpoly(2:end), 'UniformOutput', false);
% vpoly(1) = cellfun(@reversePolygon, vpoly(1), 'UniformOutput', false);
bpoly = mb.visilibity2boost(vpoly);
E_r = mb.radialPolygonSplitting(bpoly);
[E_r] = mb.steinerPointRemoval(vpoly, E_r);
P_c = convexPolygonCreation(vpoly, E_r);

%% Test with merge

filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);
cla;
hold on;
axis equal;
% vpoly = c_Poly(:,1);
vpoly = cellfun(@(x) x(1:end-1, :)*100,  c_Poly(:,1), 'UniformOutput', false);
% vpoly{4} = circshift(vpoly{4}, -1, 1);
vpoly(2:end) = cellfun(@flipud, vpoly(2:end), 'UniformOutput', false);
%%%
vpoly{1} = [vpoly{1}; vpoly{1}(1,1) 5000; vpoly{1}(1,1)+200 4500; vpoly{1}(1,1) 4000];
% vpoly(1) = cellfun(@reversePolygon, vpoly(1), 'UniformOutput', false);
drawPolygon(vpoly);
%%
bpoly = mb.visilibity2boost(vpoly);
E_r = mb.radialPolygonSplitting(bpoly);
[E_r] = mb.steinerPointRemoval(vpoly, E_r)
[E_r] = mb.steinerPointRemoval(vpoly, E_r)

%%
cla;
cellfun(@(x) drawEdge(x.edge), E_r);


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
