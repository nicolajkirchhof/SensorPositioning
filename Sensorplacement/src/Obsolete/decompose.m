function pc = environment_decompose(pc, verbose)
% function environment_decompose calculates the polygon decompositions on which all
% heuristics and bounds are based.
if nargin < 2 || isempty(verbose)
    verbose = pc.common.verbose;
end

%% FILL ALL DECOMPOSIION TYPES

if isempty(pc.environment.combined.poly)
    pc = environment_combined(pc);
end
[obstacle_expansion] = pcd_obstacle_expansion(pc.environment.combined.poly);
splits_obstacle_expansion = split_polys(obstacle_expansion, pc.sensors.distance.max);
%%
hertel_mehlhorn = pcd_hertel_mehlhorn(pc.environment.combined.poly);
splits_hertel_mehlhorn = split_polys(hertel_mehlhorn, pc.sensors.distance.max);
keil_snoyink = pcd_keil_snoeyink(pc.environment.combined.poly);
splits_keil_snoyink = split_polys(keil_snoyink, pc.sensors.distance.max);
ear_clipping = triangulation_ear_clipping(pc.environment.combined.poly);
splits_ear_clipping = split_polys(ear_clipping, pc.sensors.distance.max);
opt_length = triangulation_opt_length(pc.environment.combined.poly);
splits_opt_length = split_polys(opt_length, pc.sensors.distance.max);
delaunay_tri = triangulation_delaunay(pc.environment.combined.poly);
splits_delaunay = split_polys(delaunay_tri, pc.sensors.distance.max);

if verbose
    fun_legend_off =@(h) set(get(get(h,'Annotation'),'LegendInformation'),...
        'IconDisplayStyle','off'); % Exclude line from legend
    figure, axis equal, hold on; subplot(2,3,1);
    draw_environment(pc);
    hm = mb.drawPolygon(hertel_mehlhorn.polys, 'color', 'g');
    legend(hm, 'Hertel Mehlhorn');
    arrayfun(fun_legend_off, hm(2:end));
    subplot(2,3,2);
    ks = mb.drawPolygon(keil_snoyink.polys, 'color', 'r');
    legend(ks, 'Keil Snoeyink');
    arrayfun(fun_legend_off, ks(2:end));
    subplot(2,3,3);
    oe = mb.drawPolygon(obstacle_expansion.polys, 'color', 'b');
    legend(oe, 'Obstacle Expansion');
    arrayfun(fun_legend_off, oe(2:end));
    subplot(2,3,4);
    dl = mb.drawPolygon(delaunay_tri.polys, 'color', 'g');
    legend(dl(1), 'Delaunay Triangulation');
    arrayfun(fun_legend_off, dl(2:end));
    subplot(2,3,5);
    dl = mb.drawPolygon(ear_clipping.polys, 'color', 'r');
    legend(dl(1), 'Ear Clipping Triangulation');
    arrayfun(fun_legend_off, dl(2:end));
    subplot(2,3,6);
    dl = mb.drawPolygon(opt_length.polys, 'color', 'b');
    legend(dl(1), 'Opt length Triangulation');
    arrayfun(fun_legend_off, dl(2:end));

    legend('off');
    legend('show');
end

pc.environment.decompositon.convex.obstacle_expansion = obstacle_expansion;
pc.environment.decompositon.convex.obstacle_expansion.split = splits_obstacle_expansion;
pc.environment.decompositon.convex.hertel_mehlhorn = hertel_mehlhorn;
pc.environment.decompositon.convex.hertel_mehlhorn.splits = splits_hertel_mehlhorn;
pc.environment.decompositon.convex.keil_snoeyink = keil_snoyink;
pc.environment.decompositon.convex.keil_snoeyink.splits = splits_keil_snoyink;
pc.environment.decompositon.triangular.delauny = delaunay_tri;
pc.environment.decompositon.triangular.delauny.splits = splits_delaunay;
pc.environment.decompositon.triangular.ear_clipping = ear_clipping;
pc.environment.decompositon.triangular.ear_clipping.splits = splits_ear_clipping;
pc.environment.decompositon.triangular.opt_length = opt_length;
pc.environment.decompositon.triangular.opt_length.splits = splits_opt_length;
pc.environment.decompositon.triangular.opt_length.poly_steinerpoints = [];

function [split] = split_polys(decomp, max_distance)
split = [];
for idr = 1:numel(decomp.polys)
    is_too_large = any(mb.polygonInterpointDistances(decomp.polys{idr})>max_distance);
    if is_too_large
        error('Splitting of large polygons not implemented');
    end
end

% function [split] = split_triangulation(triangulation, max_length)
% %polygonArea for boost polygon
% for idr = 1:numel(triangulation.polys)
%     is_too_large = any(mb.polygonInterpointDistances(decomp.polys{idr})>max_distance);
%     if is_too_large
%         middlept = triangulation(:,ids(1))+int64(0.5*lines(ids(1),:))';
%         newtriags = {[triangulation(:,ids(1)), middlept, triangulation(:, ids(3)), triangulation(:,ids(1))], [triangulation(:,ids(2)), triangulation(:, ids(3)), middlept, triangulation(:,ids(2))]};
%         fun_triangleSplit = @(x) mb.triangleSplit(x, max_length);
%         newtriags = cellfun(fun_triangleSplit, newtriags, 'uniformoutput', false);
%         split = mb.flattenPolygon(newtriags);
%     else
%         split = {triangulation};
%     end
% end

function pc = environment_combined(pc)
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
    pc.environment.unmountable.edges = cellfun(@(pts) true(1, size(pts,2)), poly_wo_obstacles, 'uniformoutput', false);
    pc.environment.unmountable.points = cellfun(@(pts) true(1, size(pts,2)), poly_wo_obstacles, 'uniformoutput', false);
    
else
    %%
    pc.environment.combined.poly = poly_wo_mountables{1};
    pc.environment.unmountable.edges = cellfun(@(pts) true(1, size(pts,2)), poly_wo_mountables, 'uniformoutput', false);
    pc.environment.unmountable.points = cellfun(@(pts) true(1, size(pts,2)), poly_wo_mountables, 'uniformoutput', false);
end

function [decomp] = pcd_obstacle_expansion(inpoly)
[outpolys, cutinfo, pcd] = mb.polygonConvexDecomposition(inpoly, true);
decomp.polys = outpolys;

function [decomp] = pcd_hertel_mehlhorn(inpoly)
[outpolys] = polypartition(inpoly, 3);
decomp.polys = outpolys;

function [decomp] = pcd_keil_snoeyink(inpoly)
[outpolys] = polypartition(inpoly, 4);
decomp.polys = outpolys;


function decomp = triangulation_ear_clipping(inpoly)
[outpolys] = polypartition(inpoly, 0);
decomp.polys = outpolys;

function decomp = triangulation_opt_length(inpoly)
[outpolys] = polypartition(inpoly, 1);
decomp.polys = outpolys;


function [triang] = triangulation_delaunay(inpoly)
verticies = unique(cell2mat(inpoly)', 'rows', 'stable');
%% calculate edges as vertex indices for each polygon separately
indices_edges = @(x) [(1:size(x, 2)-1)', [(2:size(x, 2)-1)'; 1]];
inpoly_flat = mb.flattenPolygon(inpoly);
edges_cell = cellfun(indices_edges, inpoly_flat, 'uniformoutput', false);
sizem = @(x) size(x, 2)-1;
offsets = cellfun(sizem, inpoly_flat(1:end-1));
% add offsets for 2nd... polygon edges
for idedge = numel(edges_cell):-1:2
    offset = sum(offsets(1:idedge-1));
    edges_cell{idedge} = edges_cell{idedge}+offset;
end
delaunay_edges = cell2mat(edges_cell');
delaunay_triangles = DelaunayTri(double(verticies), delaunay_edges);
% calculate triangulation
delaunay_face_ids = delaunay_triangles(delaunay_triangles.inOutStatus, :);
% triplot(delaunay_face_ids, verticies(:,1), verticies(:,2));
delaunay_verticies = verticies(delaunay_face_ids', :);
num_polys = size(delaunay_verticies, 1)/3;
polys_open = mat2cell(delaunay_verticies', 2,ones(num_polys,1)*3);
fun_correctPolys = @(x) [x , x(:,1)];
triang.polys = cellfun(fun_correctPolys, polys_open, 'uniformoutput', false);

% Add poly_cutinfos for every polygon and steiner points for every splittet polygon

% fun_splitTriags = @(x) mb.triangleSplit(x, pc.sensors.distance.max);
% polys_trimmed = cellfun(fun_splitTriags, delaunay_polys_closed);
%%
% poly_angles = cellfun(@mb.triangleAngles, polys_trimmed, 'uniformoutput', false);
% pc.sensors.angle = deg2rad(pc.sensors.fov);
% poly_angles = sort(cell2mat(poly_angles'), 2, 'descend');
% % only the two smaller angles are relevant
% relevant_angles_upper = poly_angles(:,2:3);
% pc.model.coverage.cutoff.upper.triangulation = sum(sum(ceil(relevant_angles_upper./pc.sensors.angle)));
% write_log('coverage_upper_cutoff_by_triangulation has calculated a upper bound of %d', pc.model.coverage.cutoff.upper.triangulation);

