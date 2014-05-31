function [ workspace_positions ] = iterative( environment, options )
%ITERATIVE Iterative discretization of the environment based on
% max_cell_length and additional positions Configurations.Workspace.iterative
import Discretization.Workspace.*;
placeable_ring = mb.expandPolygon(environment.boundary.ring, -options.wall_distance);
p1 = min(placeable_ring{1}, [], 2);
p2 = max(placeable_ring{1}, [], 2);
region = [p1 p2];

celllength = options.cell.length(2);
x_ticks = region(1,1):celllength:region(1,2);
y_ticks = region(2,1):celllength:region(2,2);
[grid_x, grid_y] = meshgrid(x_ticks, y_ticks);
initial_positions = [grid_x(:)'; grid_y(:)'];

if options.positions.additional == 0
    workspace_positions = initial_positions;
    return
end

%% refine grid
refined_grid = [];
additional_positions = [];
celllength = celllength/2;

while options.positions.additional >= size(refined_grid, 2)
    additional_positions = [additional_positions, refined_grid];
    x_ticks_num = length(x_ticks);
    y_ticks_num = length(y_ticks);
    x_ticks_ref = region(1,1):celllength:region(1,2);
    y_ticks_ref = region(2,1):celllength:region(2,2);
    x_ticks_ref(1:2:x_ticks_num*2-1) = x_ticks;
    y_ticks_ref(1:2:y_ticks_num*2-1) = y_ticks;
    
    [grid_x_ref, grid_y_ref] = meshgrid(x_ticks_ref, y_ticks_ref);
    refined_grid = setdiff([grid_x_ref(:), grid_y_ref(:)], [grid_x(:), grid_y(:)], 'rows')';
    
    x_ticks = x_ticks_ref;
    y_ticks = y_ticks_ref;
    grid_x = grid_x_ref;
    grid_y = grid_y_ref;
end

%%
additional_positions = options.positions.additional;
index_range = {[1:size(refined_grid, 2)]};
selected_indexes = nan(1, additional_positions);
cnt = 1;
%%
while additional_position > 0
    %%
    mid_indices = cellfun(@(array) ceil(numel(array)/2), index_range, 'uniformoutput', false);
    selected_indexes(cnt:cnt+numel(mid_indices)-1) = cell2mat(mid_indices);
    remaining_indexes = cellfun(@(array, idx){index_range{1}(1:mid_indices{1}-1), index_range{1}(mid_indices{1}+1:end)}, index_range, mid_indices,'uniformoutput', false);
    remaining_indexes = [remaining_indexes{:}];
%     selected_indexes = cellfun(@(array, idx)split_array_wo_index(index_range{1}, mid_indices{1}), index_range, mid_indices, 'uniformoutput', false);
end


return;
%% TEST
close all; 
clear all;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config = Configurations.Discretization.iterative;
environment = Environment.load(filename);
options = config.workspace;


%%
grid = create_grid(region, options.cell.length(2));
%% additional grid points

grid_2 = create_grid(region, options.cell.length(2)/2);
points_left = options.positions.additional;
% midpoint = 

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