function [ lut ] = prepare_lut( input, sol )
%PREPARE_LUT Summary of this function goes here
%   Detailed explanation goes here

lut = load('tmp/contours/contours.mat');

lut.ply = input.environment.combined;
lut.ply_to_cover = bpolyclip(input.environment.combined, input.environment.occupied, 0, 1, 100, 1); 

gsp = input.discretization.sp(1:2, sol.sensors_selected)';
lut.phi = normalizeAngle(input.discretization.sp(3, sol.sensors_selected))' ./ (2*pi);

lut.placeable_edges_cell = cellfun(@(x,y) x(y, :), input.environment.combined_edges, input.environment.placable_edges, 'uniformoutput', false);
lut.placeable_edges = cell2mat(lut.placeable_edges_cell(:));
placeable_edgelenghts = edgeLength(lut.placeable_edges);
lut.placeable_edgelenghts_scale = sum(placeable_edgelenghts);
lut.placeable_edgelenghts_lut = cumsum([0; placeable_edgelenghts])/sum(placeable_edgelenghts);
placeable_edges_dir = (-lut.placeable_edges(:, 1:2) + lut.placeable_edges(:, 3:4));
lut.placeable_edges_dir = bsxfun(@rdivide, placeable_edges_dir, sqrt(sum(placeable_edges_dir.^2, 2)));




%%
is_poe = isPointOnEdge(gsp, lut.placeable_edges);
edge_id = arrayfun(@(x) find(is_poe(x, :)), 1:size(is_poe, 1), 'uniformoutput', false);
flt_gt_one = cellfun(@(x) numel(x)>1, edge_id);

for id = find(flt_gt_one)
    is_first_first = any(distancePoints(gsp(id, :),  lut.placeable_edges(:, 1:2)) < 10);
    if is_first_first
       edge_id{id} = edge_id{id}(1);
    else
       edge_id{id} = edge_id{id}(2);
    end
end
edge_ids = cell2mat(edge_id);
dst_to_first = arrayfun(@(idpt, idedge) distancePoints(gsp(idpt,:), lut.placeable_edges(idedge, 1:2)), 1:numel(edge_ids), edge_ids);
dst_to_first_scaled = dst_to_first/lut.placeable_edgelenghts_scale;
lut.x = lut.placeable_edgelenghts_lut(edge_ids) + dst_to_first_scaled(:);


end

