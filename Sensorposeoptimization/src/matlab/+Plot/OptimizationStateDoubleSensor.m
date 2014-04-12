function OptimizationStateDoubleSensor(state, num_sensors, axis_limits, plot_figure, reference)
if nargin < 4 || isempty(plot_figure)
    curr_fig = get(0, 'CurrentFigure');
    plot_figure = figure;
else 
    curr_fig = get(0, 'CurrentFigure');
    set(0, 'CurrentFigure', plot_figure);
    cla;
end

fov_2 = Mltools.deg2rad(24);
length = 3;
colors = hsv(num_sensors*2);
sensors = {};
cnt = 1;
hold on;
for i = 1:4:num_sensors*4
    %first sensor
    pix_geom_points = geom2d.circleArcAsCurve(...
        [state(i,1)...
        ,state(i+1,1)...
        ,length...
        ,state(i+2,1)-fov_2...
        ,state(i+2,1)+fov_2]...
        ,100);
    % add sensor origin as last point
    pix_geom_points(end+1, :) = [state(i,1), state(i+1,1)]; %#ok<AGROW>
    
    
    sensors{cnt} = geom2d.fillPolygon(pix_geom_points,...
        colors(cnt,:));
    alpha(sensors{end}, 0.3);
    cnt = cnt+1;
    %second sensor
    pix_geom_points = geom2d.circleArcAsCurve(...
        [state(i,1)...
        ,state(i+1,1)...
        ,length...
        ,state(i+3,1)-fov_2...
        ,state(i+3,1)+fov_2]...
        ,100);
    % add sensor origin as last point
    pix_geom_points(end+1, :) = [state(i,1), state(i+1,1)]; %#ok<AGROW>
    
    
    sensors{cnt} = geom2d.fillPolygon(pix_geom_points,...
        colors(cnt,:));
    alpha(sensors{end}, 0.3);
    cnt = cnt+1;
    %colors(((i-1)*rsp.sensor_config.pixgeom(2))+pixi,:));
end

plot(state(num_sensors*4+1:2:end, 1),state(num_sensors*4+2:2:end,1),'x');

if nargin > 2 && ~isempty(axis_limits)
    axis(axis_limits);
end

if nargin > 4 
    plot(reference(:, 1), reference(:,2), 'o');
end

set(0, 'CurrentFigure', curr_fig);
end

