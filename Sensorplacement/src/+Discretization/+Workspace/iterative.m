function [ workspace_positions ] = iterative( environment, options )
%ITERATIVE Iterative discretization of the environment based on
% max_cell_length and additional positions Configurations.Workspace.iterative
import Discretization.Workspace.*;
placeable_ring = mb.expandPolygon(environment.boundary.ring, -options.wall_distance);
p1 = min(placeable_ring{1}, [], 2);
p2 = max(placeable_ring{1}, [], 2);
region = [p1 p2];

x_ticks = p1(1):options.cell.length(2):p2(1);
y_ticks = p1(2):options.cell.length(2):p2(2);
[grid_x, grid_y] = meshgrid(x_ticks, y_ticks);
grid = [grid_x(:)'; grid_y(:)'];
%%
x_ticks = p1(1):options.cell.length(2)/2:p2(1);
y_ticks = p1(2):options.cell.length(2)/2:p2(2);
[grid_x, grid_y] = meshgrid(x_ticks, y_ticks);
grid_2 = [grid_x(:)'; grid_y(:)'];
%%
grid = create_grid(region, options.cell.length(2));
%% additional grid points

grid_2 = create_grid(region, options.cell.length(2)/2);
points_left = options.positions.additional;
midpoint = 

while points_left > 0
    


end 

%%

%%
switch workspace.sampling_technique
    case common.sampling_techniques.grid
        num_pts_x = ceil(dp(1)/workspace.grid_position_distance);
        num_pts_y = ceil(dp(2)/workspace.grid_position_distance);
    case common.sampling_techniques.uniform
        num_pts_x = ceil(dp(1)/workspace.x_axis_grid_distance);
        num_pts_y = ceil(dp(2)/workspace.y_axis_grid_distance);
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
% for idp = 1:numel(environment.wall.ring)
workspace.environment.walls = mb.expandPolygon(environment.walls.ring, -workspace.wall_distance);

[in_poly, on_walls] = binpolygon(pts, workspace.environment.walls);
pts = pts(:, in_poly&~on_walls);

if ~isempty(environment.occupied.poly)
%     occupied = mb.expandPolygon(environment.occupied.poly, workspace.wall_distance);
%     occupied_merged = bpolyclip_batch(workspace.environment.occupied, 3, 1:numel(occupied), common.bpolyclip_batch_options);
%     workspace.environment.occupied = occupied_merged{1};
%     [in_occupied, ~] = binpolygon(pts, workspace.environment.occupied);
    [in_occupied, ~] = binpolygon(pts, environment.occupied.poly);
    pts = pts(:, ~in_occupied);
end

if ~isempty(environment.obstacles.poly)
%     workspace.environment.obstacles = mb.expandPolygon(environment.obstacles.poly, workspace.wall_distance);
    [in_obstacle, ~] = binpolygon(pts, environment.obstacles.poly);
    pts = pts(:, ~in_obstacle);
end
%%
if ~isempty(environment.mountable.poly)
    workspace.environment.mountable = mb.expandPolygon(environment.mountable.poly, workspace.wall_distance);
    [in_mountable] = cell2mat(cellfun(@(poly) binpolygon(pts, poly), workspace.environment.mountable, 'uniformoutput', false)');
    pts = pts(:,~any(in_mountable,1));
end
%
problem.W = double(pts);
workspace.number_of_positions = size(pts,2);