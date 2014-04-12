function [ poly ] = randomPolygon( num_edges, seed )
%RANDOMPOLYGON Creates a random polygon as the convex hull over the given number of points 
if nargin > 1 && ~isempty(seed)
    rng(seed);
end
points = rand(num_edges,2);
cnt = 0;
max_cnt = 10;
while cnt < max_cnt;
inds = convhull(points(:,1), points(:,2));
sdiff = setdiff(1:num_edges, inds);
if ~isempty(sdiff)
    points(sdiff,:) = rand(numel(sdiff),2);
else
    poly = points(inds(1:end-1), :);
    return;
end
end

poly = [];
warning('poly edges where not reached');



