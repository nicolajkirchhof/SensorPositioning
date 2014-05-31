function grid = create_centered_grid(region, celllength)
%% CREATE_GRID creates a grid that is centered between [min, max] point and 
%   defined by cell length
% region : the 2d region where the grid is placed
% celllength : the grid cell length
range = diff(region, 1, 2); %p2-p1;
num_pts_grid = range./celllength;
grid_offset = (range - (num_pts_grid-1)*celllength)/2;
grid_anchors = [region(:,1)+grid_offset region(:,2)-grid_offset];
%% initial grid sampling
x_samples = grid_anchors(1,1):celllength:grid_anchors(1,2);
y_samples = grid_anchors(2,1):celllength:grid_anchors(2,2);
[grid_x, grid_y] = meshgrid(x_samples, y_samples);
grid = [grid_x(:)'; grid_y(:)'];
