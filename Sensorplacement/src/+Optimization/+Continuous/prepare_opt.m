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

is_poe = arrayfun(@(x,y) isPointOnEdge([x,y], opt.placeable_edges, 1e-10), gsp(:,1), gsp(:,2), 'uniformoutput', false);
is_poe = cell2mat(is_poe(:)');

if ~all(any(is_poe, 1)) || any(sum(is_poe, 1)>2)
    error('Coverage is not compleate');
end

edge_id = arrayfun(@(x) find(is_poe(:, x)), 1:size(is_poe, 2), 'uniformoutput', false);
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
%%

dst_to_first = arrayfun(@(idpt, idedge) distancePoints(gsp(idpt,:), opt.placeable_edges(idedge, 1:2)), 1:numel(edge_ids), edge_ids);
dst_to_first_scaled = dst_to_first/opt.placeable_edgelenghts_scale;
flt_eps_sub = dst_to_first_scaled > 10/opt.placeable_edgelenghts_scale;
dst_to_first_scaled(flt_eps_sub) = dst_to_first_scaled(flt_eps_sub) - eps;
dst_to_first_scaled(~flt_eps_sub) = dst_to_first_scaled(~flt_eps_sub)+eps;
opt.x = opt.placeable_edgelenghts_lut(edge_ids) + dst_to_first_scaled(:);

%%
x = [opt.x(:); opt.phi(:)];
id_mid = numel(x)/2;
phi = x(id_mid+1:end);
x = x(1:id_mid);
phi = phi(:);
x = x(:);
%%

ids_before = arrayfun(@(x) sum(opt.placeable_edgelenghts_lut(1:end-1)<=x), x);
% dist_to_first = (x-placeable_edgelenghts_lut(ids_before))*placeable_edgelenghts_scale;
% gsp = placeable_edges(ids_before, 1:2) + bsxfun(@times, placeable_edges_dir(ids_before,:), dist_to_first);
% sp = [gsp'; phi(:)'*(2*pi)];
id_error = find(edge_ids(:)-ids_before(:));
if ~isempty(id_error)
    error('SP %d is not correctly translated\n', id_error);
end

end

