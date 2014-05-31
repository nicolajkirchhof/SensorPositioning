function grid = leftdown_aligned_grid(region, celllength)
%% LEFTDOWN_ALIGNED_GRID creates a grid that is aligned with min point
%   of region, which is defined by [min, max] point and cell length
% region : the 2d region where the grid is placed
% celllength : the grid cell length

x_ticks = region(1,1):celllength:region(1,2);
y_ticks = region(2,1):celllength:region(2,2);
[grid_x, grid_y] = meshgrid(x_ticks, y_ticks);
grid = [grid_x(:)'; grid_y(:)'];
