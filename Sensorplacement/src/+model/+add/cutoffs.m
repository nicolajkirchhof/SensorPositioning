function pc = model_cutoffs(pc)

% lower upper bound by area;
% pc =coverage_lower_cutoff_by_area(pc);
% pc = calculate_lower_bound_by_convex1coverage(pc);
pc =coverage_lower_cutoff_by_visibility(pc);
pc =coverage_cutoff_by_pcdcoverage(pc);
% pc = calculate_upper_bound_by_area(pc);
pc = coverage_upper_cutoff_by_convex2coverage(pc);
% pc = coverage_upper_cutoff_by_triangulation(pc);

%% TO BE IMPLEMENTED
% pc = distance_upper_by_???
% pc = distance_lower_by_???
% pc = directional_upper_by_???
% pc = directional_lower_by_???



function pc =coverage_cutoff_by_pcdcoverage(pc)
%% Calculates values for the cutoffs by using the pcd polygon decomposition
% at least two edges of each pcd polygon have to be covered with sensors as
% an upper bound when no quality constraints are applied
choosen_points = calculatePlacementInConvexDecomposition(pcd, pc.sensors);
%%
pc.model.coverage.cutoff.lower.pcd1coverage = size(choosen_points{1}, 2);
pc.model.coverage.cutoff.lower.pcd1coverage.points = choosen_points{2};
pc.model.coverage.cutoff.upper.pcd2coverage = size(choosen_points{1}, 2) + size(choosen_points{2}, 2);
pc.model.coverage.cutoff.lower.pcd2coverage.points = [choosen_points{1} choosen_points{2}];
write_log('calculate_bounds_by_pcdcoverage has calculated a lower bound of %d and upper of %d', pc.model.coverage.cutoff.lower.pcd1coverage, pc.model.coverage.cutoff.upper.pcd2coverage);

function pc =coverage_lower_cutoff_by_visibility(pc)
%% lowerbound visibility polygon
boundary_points = mb.polygonVerticies(pc.environment.walls.ring);
boundary_angles = mb.polygonAngles(pc.environment.walls.ring);
%% sort by angle size for greedy search 
[boundary_angles_sorted, bs_idx] = sort(cell2mat(boundary_angles'), 'descend');
% [boundary_angles_sorted, bs_idx] = sort(cell2mat(boundary_angles'), 'ascend');
boundary_points_sorted = int64(boundary_points(bs_idx, :));
choosen_points = {};
environment_visilibity = mb.boost2visilibity(pc.environment.combined.poly);
%%
while ~isempty(boundary_angles_sorted)
    % use greates angle for first sensor placement
    %%
    choosen_points{end+1} = boundary_points_sorted(1,:);
    vis_poly = visilibity(boundary_points_sorted(1,:)', environment_visilibity, 1);
    coverd_points = binpolygon(boundary_points_sorted', int64(vis_poly{1}), 1);
    boundary_angles_sorted = boundary_angles_sorted(~coverd_points);
    boundary_points_sorted = boundary_points_sorted(~coverd_points, :);
end
pc.model.coverage.cutoff.lower.visibility = 2*numel(choosen_points);
pc.model.coverage.cutoff.lower_visibility.choosen_points = cell2mat(choosen_points');
write_log('calculate_lower_bound_by_visibility has calculated a lower bound of %d', 2*numel(choosen_points));
%%
% choosen_points = cell2mat(choosen_points');
% draw_workspace(pc); hold on;
% drawPoint(choosen_points, 'color', 'k', 'marker', 'p', 'markersize', 10);

function pc = coverage_upper_cutoff_by_convex2coverage(pc)
convex_partition = polypartition(pc.environment.combined.poly, 3);
convex_partition_angles = mb.polygonAngles(convex_partition);
choosen_points= {};
num_points = 0;
%%
for idp = 1:numel(convex_partition)
pc.sensors.angle = deg2rad(pc.sensors.fov);
[angles_sorted idx_angles] = sort(convex_partition_angles{idp});    
% points_sorted = points(:, idx_angles);
choosen_points{end+1} = convex_partition{idp}(:, idx_angles(1:2));
num_points = num_points + ceil(angles_sorted(1)/pc.sensors.angle)+ceil(angles_sorted(2)/pc.sensors.angle);
end
%%
pc.model.coverage.cutoff.upper.convex2coverage = num_points;
pc.model.coverage.cutoff.upper_convex2coverage.choosen_points = cell2mat(choosen_points);
pc.model.coverage.cutoff.upper_convex2coverage.convex_partition = convex_partition;
write_log('coverage_upper_cutoff_by_convex2coverage has calculated a upper bound of %d', pc.model.coverage.cutoff.upper_values(pc.model.coverage.cutoff.upper_types.convex2coverage));

% not needed since it is alway worse than one coverage
function pc =coverage_lower_cutoff_by_area(pc)
pc.environment.area = mb.polygonArea(pc.environment.combined.poly);
pc.sensors.area = deg2rad(pc.sensors.fov)*pc.sensors.distance^2*0.5;
pc.model.coverage.cutoff.lower.area = ceil(pc.environment.area*2/pc.sensors.area);
write_log('calculate_lower_bound_by_area has calculated a lower bound of %d', pc.model.coverage.cutoff.lower_values(pc.model.coverage.cutoff.lower_types.area));

% Not needed, since it is always worse than convex decomp
function pc = coverage_upper_cutoff_by_triangulation(pc)
%% calculate upper bound
pc.environment.verticies = unique(cell2mat(pc.environment.poly.flatten)', 'rows', 'stable');
%% calculate edges as vertex indices for each polygon separately
indices_edges = @(x) [(1:size(x, 2)-1)', [(2:size(x, 2)-1)'; 1]];
edges_cell = cellfun(indices_edges, pc.environment.poly.flatten, 'uniformoutput', false);
sizem = @(x) size(x, 2)-1;
offsets = cellfun(sizem, pc.environment.poly.flatten(1:end-1));
% add offsets for 2nd... polygon edges
for idedge = numel(edges_cell):-1:2
    offset = sum(offsets(1:idedge-1));
    edges_cell{idedge} = edges_cell{idedge}+offset;
end
pc.environment.edges.delaunay = cell2mat(edges_cell');
pc.environment.triangulation.delaunay = DelaunayTri(double(pc.environment.verticies), pc.environment.edges.delaynay);
% calculate triangulation
pc.environment.triangulation.face_indices = pc.environment.triangulation.delaunay(pc.environment.triangulation.delaunay.inOutStatus, :);
% triplot(pc.environment.triangulation.face_indices, pc.environment.verticies(:,1), pc.environment.verticies(:,2));
pc.environment.triangulation.verticies = pc.environment.verticies(pc.environment.triangulation.face_indices', :);
num_polys = size(pc.environment.triangulation.verticies, 1)/3;
polys_open = mat2cell(pc.environment.triangulation.verticies', 2,ones(num_polys,1)*3);
fun_correctPolys = @(x) [x , x(:,1)];
pc.environment.triangulation.polys = cellfun(fun_correctPolys, polys_open, 'uniformoutput', false);
fun_splitTriags = @(x) mb.triangleSplit(x, pc.sensors.distance);
polys_trimmed = cellfun(fun_splitTriags, pc.environment.triangulation.polys);
%%
poly_angles = cellfun(@mb.triangleAngles, polys_trimmed, 'uniformoutput', false);
pc.sensors.angle = deg2rad(pc.sensors.fov);
poly_angles = sort(cell2mat(poly_angles'), 2, 'descend');
% only the two smaller angles are relevant
relevant_angles_upper = poly_angles(:,2:3);
pc.model.coverage.cutoff.upper.triangulation = sum(sum(ceil(relevant_angles_upper./pc.sensors.angle)));
write_log('coverage_upper_cutoff_by_triangulation has calculated a upper bound of %d', pc.model.coverage.cutoff.upper.triangulation);