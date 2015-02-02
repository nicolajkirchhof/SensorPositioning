figure;
num_sp_selected = cellfun(@(x) numel(x.sensors_selected), gco);

num_sp = 0:10:500;
num_wpn = 0:10:500;
[X Y] = meshgrid(num_sp, num_wpn);

scatter(X(:), Y(:), num_sp_selected(:)*10, num_sp_selected(:), 'fill');