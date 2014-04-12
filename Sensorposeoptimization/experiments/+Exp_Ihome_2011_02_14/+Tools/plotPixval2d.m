function plotPixval2d( syscal_config, pixval, reference )
%PLOTPIXVAL2D Summary of this function goes here
%   Detailed explanation goes here


cla;
hold on;

colors = hsv(syscal_config.NumSensors);

for idx_sensor = 1:syscal_config.NumSensors
    % SG filter hack
    for i = 1:100, norm_pixval = syscal_config.preprocessors{idx_sensor}.apply(pixval(1,idx_sensor*8-7:idx_sensor*8)'); end
    pixfov = Mltools.deg2rad(6);
    pixgeom = [1 8];
    % sensor properties
    sens_rot = syscal_config.sensor_objects{idx_sensor}.Orientation(3);
    sens_transX = syscal_config.sensor_objects{idx_sensor}.Position(1);
    sens_transY = syscal_config.sensor_objects{idx_sensor}.Position(2);
    sensivity_length = 5; % 5m
    
    %
    plot(sens_transX, ...
        sens_transY, 'o');
    % add text to graphic
    tcoordx = sens_transX-(20*sin(sens_rot));
    tcoordy = sens_transY-(20*cos(sens_rot));
    % swap for second and forth
    if xor(tcoordx < sens_transX, tcoordy < sens_transY)
        tcoordx = sens_transX+(20*sin(sens_rot));
        tcoordy = sens_transY+(20*cos(sens_rot));
    end
    text(tcoordx,...
        tcoordy, ['S' num2str(idx_sensor)]);
    
    % create sensor pixel arcs
    pixel = {};
    
    %pixelrot = fliplr(-(pixgeom(2)/2)*pixfov:pixfov:pixfov*(pixgeom(2)/2));
    pixelrot = -(pixgeom(2)/2)*pixfov:pixfov:pixfov*(pixgeom(2)/2);
    
    for pixi = 1:pixgeom(2)
        pix_geom_points = geom2d.circleArcAsCurve(...
            [sens_transX,...
            sens_transY,...
            sensivity_length,...
            pixelrot(pixi)+sens_rot,...
            pixelrot(pixi+1)+sens_rot],...
            100);
        % add sensor origin as last point
        pix_geom_points(end+1, :) = [sens_transX, ...
            sens_transY];
        
        pixel{end+1} = geom2d.fillPolygon(pix_geom_points,...
            colors(idx_sensor,:));
        if ~isempty(norm_pixval) && norm_pixval(pixi)>0
            alpha(pixel{end}, norm_pixval(pixi));
        else
            alpha(pixel{end}, 0);
        end
        %colors(((idx_sensor-1)*rsp.sensor_config.pixgeom(2))+pixi,:));    
    end
    plot(reference(1,1), reference(1,2), 'gx')
end
end

