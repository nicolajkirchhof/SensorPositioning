function OptimizationStateSingleSensor(state, num_sensors, plot_figure)
if nargin < 3 || isempty(plot_figure)
    curr_fig = get(0, 'CurrentFigure');
    plot_figure = figure;
else 
    curr_fig = get(0, 'CurrentFigure');
    set(0, 'CurrentFigure', plot_figure);
    cla;
end

fov_2 = Mltools.deg2rad(24);
length = 3;
colors = hsv(num_sensors);
sensors = {};
cnt = 1;
for i = 1:3:num_sensors*3
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
    hold on;
    %colors(((i-1)*rsp.sensor_config.pixgeom(2))+pixi,:));
end

plot(state(num_sensors*3+1:2:end, 1),state(num_sensors*3+2:2:end,1),'x');

if ~isempty(obj.measure_pose.reference)
    plot(obj.measure_pose.reference(:, 1), obj.measure_pose.reference(:,2), 'o');
end

set(0, 'CurrentFigure', curr_fig);
end

