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
fullgrid_positions = [];
celllength = floor(celllength/2);

while options.positions.additional >= size(refined_grid, 2)
    fullgrid_positions = [fullgrid_positions, refined_grid];
    
    % replace to avoid rounding errors
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
    celllength = floor(celllength/2);
end

num_additional_positions = options.positions.additional - size(fullgrid_positions,2);
%%
% cla; mb.drawPolygon(placeable_ring); hold on; 
% mb.drawPoint(initial_positions, 'color', 'g');
% mb.drawPoint(refined_grid);
%%

%% additional positions by two splitting
% for nap = 1:50
% num_additional_positions = nap;
%%% Test for sorted positions
sorted_positions = meshgrid_spiral_sort(grid_x, grid_y);
sorted_cleaned_positions = setdiff(sorted_positions', fullgrid_positions', 'rows', 'stable')'; 
%     cla; mb.drawPolygon(placeable_ring); hold on; 
%     mb.drawPoint(initial_positions, 'color', 'g');
%     mb.drawPoint(refined_grid);
% for i=1:size(sorted_cleaned_positions,2)
%     mb.drawPoint(sorted_cleaned_positions(:,i), 'color', 'm');
%     pause
% end
%%%
positions_lists = {sorted_cleaned_positions};
additional_partgrid_positions = nan(2, num_additional_positions);
% matrix_index_splits = {index_range};
% index_ranges = {1:size(refined_grid,2)};
cnt = 1;

while num_additional_positions > 0
    %%  
    first_position_list = positions_lists{1};
    positions_lists = positions_lists(2:end);
    index_mid = ceil(size(first_position_list, 2)/2);
    additional_partgrid_positions(:,cnt) = first_position_list(:,index_mid);
        
    list_split_1 = first_position_list(:, 1:index_mid-1);
    if ~isempty(list_split_1)
        positions_lists = [positions_lists, {list_split_1}];
    end
    list_split_2 = first_position_list(:, index_mid+1:end);
    if ~isempty(list_split_2)
        positions_lists = [positions_lists, {list_split_2}];
    end
    num_additional_positions = num_additional_positions - 1;
    cnt = cnt + 1;
end
%
% cla; mb.drawPolygon(placeable_ring); hold on; 
% mb.drawPoint(initial_positions, 'color', 'g');
% mb.drawPoint(refined_grid);
% mb.drawPoint(additional_partgrid_positions, 'color', 'k', 'marker', '.');
% pause
% end
workspace_positions = [initial_positions, fullgrid_positions, additional_partgrid_positions];

cla; mb.drawPolygon(placeable_ring); hold on; 
mb.drawPoint(initial_positions, 'color', 'g');
mb.drawPoint(fullgrid_positions);
mb.drawPoint(additional_partgrid_positions, 'color', 'k', 'marker', 'o');
return;

%% TEST
close all; 
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config = Configurations.Discretization.iterative;
environment = Environment.load(filename);
options = config.workspace;
options.positions.additional = 60;
[ workspace_positions ] = Discretization.Workspace.iterative( environment, options );
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% additional positions by two splitting with column based sorting
% for nap = 1:50
% num_additional_positions = nap;
selected_indexes = nan(1, num_additional_positions);
% selected_positions = nan(2, additional_positions);
% matrix_index_splits = {index_range};
first_position_list = {1:size(refined_grid,2)};
cnt = 1;

while num_additional_positions > 0
    %%
    index_range = first_position_list{1};
    first_position_list = first_position_list(2:end);
    
    mid_index = ceil(numel(index_range)/2);
    selected_indexes(1, cnt) = index_range(mid_index);
    list_split_1 = index_range(1:mid_index-1);
    if ~isempty(list_split_1)
        first_position_list = [first_position_list, {list_split_1}];
    end
    list_split_2 = index_range(mid_index+1:end);
    if ~isempty(list_split_2)
        first_position_list = [first_position_list, {list_split_2}];
    end
    num_additional_positions = num_additional_positions -1;
    cnt = cnt +1;
end
%
% cla; mb.drawPolygon(placeable_ring); hold on; 
% mb.drawPoint(initial_positions, 'color', 'g');
% mb.drawPoint(refined_grid);
% mb.drawPoint(refined_grid(:,selected_indexes), 'color', 'k', 'marker', '.');
% pause
% end
% return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Grid discretization DOES NOT WORK!!!
%%
for nap = 1:50
num_additional_positions = nap;
index_range = [[1;1], size(grid_x)'];
% selected_indexes = nan(2, additional_positions);
selected_positions = nan(2, num_additional_positions);
matrix_index_splits = {index_range};
cnt = 1;
%%%
%   -------  ye
%  |   |   |
%  |-------| -
%  |   |   | ym
%   -------  ys
% xs xm|   xe 
while num_additional_positions > 0
    %%
    index_range = matrix_index_splits{1};
    matrix_index_splits = matrix_index_splits(2:end);
    index_range_mid = floor(diff(index_range,1,2)/2);
    x_start = index_range(1,1);
    x_mid = index_range(1,1)+index_range_mid(1,1);
    x_end = index_range(1,2);
    y_start = index_range(2,1);
    y_mid = index_range(2,1)+index_range_mid(2,1);
    y_end = index_range(2,2);
    southwest = [[x_start;y_start], [x_mid; y_mid]];
    southeast = [[x_mid+1;y_start], [x_end; y_mid]];   
    northwest = [[x_start;y_mid+1], [x_mid; y_end]];
    northeast = [[x_mid+1;y_mid+1], [x_end; y_end]];
    matrix_index_splits = {matrix_index_splits{:}, southwest, northwest, northeast, southeast};
    
    new_position = [grid_x(x_mid, y_mid); grid_y(x_mid, y_mid)];
    
    if any(refined_grid(1,:)==new_position(1,1)&refined_grid(2,:)==new_position(2,1))
%     selected_indexes(:,cnt) = [x_mid; y_mid];
        selected_positions(:,cnt) = new_position;
        cnt = cnt + 1;
        num_additional_positions = num_additional_positions-1;
    end
end
cla; mb.drawPolygon(placeable_ring); hold on; 
mb.drawPoint(initial_positions, 'color', 'g');
mb.drawPoint(refined_grid);
mb.drawPoint(selected_positions, 'color', 'k', 'marker', '.');
pause;
end