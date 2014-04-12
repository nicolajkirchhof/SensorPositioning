function [splitted_rings] = polygonCentroidSplitting(bring, uncutable_edges, debug)
%%
gring = mb.boost2visilibity(bring);
edges = mb.ring2edges(bring);
num_pts = size(gring,1);

% get all combinations of cuttable edges
valid_edges = find(~uncutable_edges);
valid_combinations = comb2unique(valid_edges);

% compute centroid
c = polygonCentroid(gring);

proj_centroid = projPointOnEdge(c, edges);

%%

cutedges = [proj_centroid(valid_combinations(:,1),:), proj_centroid(valid_combinations(:,2),:)];
% cutedges_length = edgeLength(cutedges);
% distance cutedge centroid
cutedge_cent_dist = distancePointEdge(c, cutedges);

%[~, idx_min] = min(cutedges_length);
[~, idx_min] = min(cutedge_cent_dist);
%%
% calculate the indices of the newly created rings. Since the combinations are always calculated
% from the lower to the higher indices, the new rings are given by
% ring1 = [ proj_point1, idx_after_proj_point:idx_before_proj_point2, proj_point2 ]
% ring2 = [ proj_point1, proj_point2, idx_after_proj_point2:idx_before_proj_point1 ]
ring1_idx = valid_combinations(idx_min, 1)+1:valid_combinations(idx_min, 2);
ring2_idx = [valid_combinations(idx_min, 2)+1:num_pts, 1:valid_combinations(idx_min, 1)];

ring1 = [cutedges(idx_min, 1:2); gring(ring1_idx, :); cutedges(idx_min, 3:4)];
ring2 = [cutedges(idx_min, 1:2); cutedges(idx_min, 3:4); gring(ring2_idx, :)];

splitted_rings = mb.visilibity2boost({ring1, ring2});

%% debug
if nargin > 2 && debug
    %%
cla
axis equal
hold on;
drawPolygon(gring, 'color', 'k', 'linestyle', ':');
drawPoint(c); drawPoint(proj_centroid, 'og');
%%
drawEdge(cutedges, 'color', 'm');
drawPolygon(ring1, 'color', 'y', 'linestyle', '-');
drawPolygon(ring2, 'color', 'b', 'linestyle', '-');
drawEdge(cutedges(idx_min,:), 'color', 'g', 'linestyle', '--');
end

