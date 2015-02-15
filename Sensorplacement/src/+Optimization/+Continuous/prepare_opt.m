function [ opt ] = prepare_opt( input, sp )
%PREPARE_LUT Summary of this function goes here
%   Detailed explanation goes here

opt = load('tmp/contours/contours.mat');

opt.ply = input.environment.combined;
opt.ply_to_cover = bpolyclip(input.environment.combined, input.environment.occupied, 0, 1, 100, 1); 

gsp = sp(1:2, :)';
opt.phi = normalizeAngle(sp(3, :))' ./ (2*pi);

opt.placeable_edges_cell = cellfun(@(x,y) x(y, :), input.environment.combined_edges, input.environment.placable_edges, 'uniformoutput', false);
opt.placeable_edges = cell2mat(opt.placeable_edges_cell(:));
placeable_edgelenghts = edgeLength(opt.placeable_edges);
opt.placeable_edgelenghts_scale = sum(placeable_edgelenghts);
opt.placeable_edgelenghts_lut = cumsum([0; placeable_edgelenghts])/sum(placeable_edgelenghts);
placeable_edges_dir = (-opt.placeable_edges(:, 1:2) + opt.placeable_edges(:, 3:4));
opt.placeable_edges_dir = bsxfun(@rdivide, placeable_edges_dir, sqrt(sum(placeable_edges_dir.^2, 2)));




%%
is_poe = isPointOnEdge(gsp, opt.placeable_edges, 10);
edge_id = arrayfun(@(x) find(is_poe(x, :)), 1:size(is_poe, 1), 'uniformoutput', false);
flt_gt_one = cellfun(@(x) numel(x)>1, edge_id);

for id = find(flt_gt_one)
    is_first_first = any(distancePoints(gsp(id, :),  opt.placeable_edges(:, 1:2)) < 10);
    if is_first_first
       edge_id{id} = edge_id{id}(1);
    else
       edge_id{id} = edge_id{id}(2);
    end
end
edge_ids = cell2mat(edge_id);
dst_to_first = arrayfun(@(idpt, idedge) distancePoints(gsp(idpt,:), opt.placeable_edges(idedge, 1:2)), 1:numel(edge_ids), edge_ids);
dst_to_first_scaled = dst_to_first/opt.placeable_edgelenghts_scale;
opt.x = opt.placeable_edgelenghts_lut(edge_ids) + dst_to_first_scaled(:);


end

