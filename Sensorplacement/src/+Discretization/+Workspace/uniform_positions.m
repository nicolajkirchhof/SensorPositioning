function pc = uniform_positions(pc)

%% testinput
%%
% if isempty(pc.polymatlab)
%     if isempty(pc.poly)
%         pc.poly = read_vertices_from_file('./res/example1.environment');
%         %generate gis poly
%         pc.polycontour = convert_poly_simple2contour(pc.poly);
%     end
%     pc.polymatlab = convert_poly_simple2matlab(pc.poly);
% end

p1 = min(mb.polygonVerticies(pc.environment.walls.ring));
p2 = max(mb.polygonVerticies(pc.environment.walls.ring));
rect = [p1' p2'];
dp = abs(diff(rect,1,2));
%%%
switch pc.workspace.sampling_technique
    case pc.common.sampling_techniques.grid
        num_pts_x = ceil(dp(1)/pc.workspace.grid_position_distance);
        num_pts_y = ceil(dp(2)/pc.workspace.grid_position_distance);
    case pc.common.sampling_techniques.uniform
        num_pts_x = ceil(dp(1)/pc.workspace.x_axis_grid_distance);
        num_pts_y = ceil(dp(2)/pc.workspace.y_axis_grid_distance);
    otherwise
        error('not implemented');
end
xlnsp = linspace(p1(1), p2(1), num_pts_x);
ylnsp = linspace(p1(2), p2(2), num_pts_y);
[x_grd, y_grd] = meshgrid(xlnsp, ylnsp);
fun_combine = @(x,y) [x,y]';
pts = arrayfun(fun_combine, x_grd, y_grd, 'uniformoutput', false);
pts = int64(cell2mat(pts(:)'));


% yxgrd = repmat(ylnsp, 1, numel(xlnsp));
% xygrd = repmat(xlnsp, numel(ylnsp), 1);
%
% pts = int64(bsxfun(@plus, p1, [xygrd(:) yxgrd(:)])');

% remove everything that is not in polygon or in holes and on the walls
% for idp = 1:numel(pc.environment.wall.ring)
pc.workspace.environment.walls = mb.expandPolygon(pc.environment.walls.ring, -pc.workspace.wall_distance);

[in_poly, on_walls] = binpolygon(pts, pc.workspace.environment.walls);
pts = pts(:, in_poly&~on_walls);

if ~isempty(pc.environment.occupied.poly)
%     occupied = mb.expandPolygon(pc.environment.occupied.poly, pc.workspace.wall_distance);
%     occupied_merged = bpolyclip_batch(pc.workspace.environment.occupied, 3, 1:numel(occupied), pc.common.bpolyclip_batch_options);
%     pc.workspace.environment.occupied = occupied_merged{1};
%     [in_occupied, ~] = binpolygon(pts, pc.workspace.environment.occupied);
    [in_occupied, ~] = binpolygon(pts, pc.environment.occupied.poly);
    pts = pts(:, ~in_occupied);
end

if ~isempty(pc.environment.obstacles.poly)
%     pc.workspace.environment.obstacles = mb.expandPolygon(pc.environment.obstacles.poly, pc.workspace.wall_distance);
    [in_obstacle, ~] = binpolygon(pts, pc.environment.obstacles.poly);
    pts = pts(:, ~in_obstacle);
end
%%
if ~isempty(pc.environment.mountable.poly)
    pc.workspace.environment.mountable = mb.expandPolygon(pc.environment.mountable.poly, pc.workspace.wall_distance);
    [in_mountable] = cell2mat(cellfun(@(poly) binpolygon(pts, poly), pc.workspace.environment.mountable, 'uniformoutput', false)');
    pts = pts(:,~any(in_mountable,1));
end
%
pc.problem.W = double(pts);
pc.workspace.number_of_positions = size(pts,2);