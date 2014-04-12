function plotPixvalIntersections( syscal_config, pixval, idx_measure )
%PLOTPIXVAL2D Summary of this function goes here
%   Detailed explanation goes here


cla;
hold on;

colors = hsv(syscal_config.NumSensors*2);
pixlist = {};

pixfov = Mltools.deg2rad(6);
pixel_variance = Mltools.deg2rad(8);
position_variance = [0 0 0.25 0.25 0.25 0.25 0.25 0.25];
position_variance_dist = sqrt(2*(position_variance.*position_variance));
% sqrt(position_variance^2+position_variance^2);
orientation_offset = Mltools.deg2rad(67.5);
pixgeom = [1 16];

calcPositionOffset = @(x, y, phi, r) [x+cos(phi)*r, y+sin(phi)*r];

for idx_sensor = 1:2:syscal_config.NumSensors*2
    idx_pixlist = 1;
    % SG filter hack
    
    
    % sensor properties
    sens_rot1 = syscal_config.sensor_objects{idx_sensor}.Orientation(3);
    sens_rot2 = syscal_config.sensor_objects{idx_sensor+1}.Orientation(3);
    
    sensor1_pixvals = pixval{idx_sensor,idx_measure};
    sensor2_pixvals = pixval{idx_sensor+1,idx_measure};
    if isempty(sensor1_pixvals), sensor1_pixvals = zeros(8,1); end
    if isempty(sensor2_pixvals), sensor2_pixvals = zeros(8,1); end
    
    pixelrot = (-(pixgeom(2)/4)*pixfov:pixfov:pixfov*(pixgeom(2)/4));
    
    if sens_rot1 > sens_rot2
        sensor_pixvals = [sensor2_pixvals; sensor1_pixvals];
        sensor_pixrot = [pixelrot(1:8)'+sens_rot2, pixelrot(2:9)'+sens_rot2;...
            pixelrot(1:8)'+sens_rot1 pixelrot(2:9)'+sens_rot1];
    else
        sensor_pixvals = [sensor1_pixvals; sensor2_pixvals];
        sensor_pixrot = [pixelrot(1:8)'+sens_rot1 pixelrot(2:9)'+sens_rot1;...
            pixelrot(1:8)'+sens_rot2, pixelrot(2:9)'+sens_rot2];
    end
    
    sens_transX = syscal_config.sensor_objects{idx_sensor}.Position(1);
    sens_transY = syscal_config.sensor_objects{idx_sensor}.Position(2);
    
    if position_variance(idx_sensor) > 0
    rectangle('Position',[sens_transX-position_variance(idx_sensor),sens_transY-position_variance(idx_sensor),position_variance(idx_sensor)*2,position_variance(idx_sensor)*2])
    end
    sensivity_length = 10; % 5m
    
    %
    pmax = calcPositionOffset(sens_transX, sens_transY, (sens_rot1+orientation_offset), position_variance_dist(idx_sensor));
    pmin = calcPositionOffset(sens_transX, sens_transY, (sens_rot2-orientation_offset), position_variance_dist(idx_sensor));

    plot(sens_transX, sens_transY, 'o');
    plot(pmax(1) ,pmax(2), 'o');
    plot(pmin(1), pmin(2), 'o');
    
    %     tcoordx = sens_transX-(20*sin(sens_rot));
    %     tcoordy = sens_transY-(20*cos(sens_rot));
    %     % swap for second and forth
    %     if xor(tcoordx < sens_transX, tcoordy < sens_transY)
    %         tcoordx = sens_transX+(20*sin(sens_rot));
    %         tcoordy = sens_transY+(20*cos(sens_rot));
    %     end
    %     text(tcoordx, tcoordy, ['S' num2str(idx_sensor)]);
    
    % create sensor sensor_pixelcones arcs
    sensor_pixelcones = {};
    sensor_filled_cones = {};
    count_pixelcones = 1;
    conesave = [];
    for pixi = 1:pixgeom(2)
        if sensor_pixvals(pixi) > 0
%             pix_geom_points = geom2d.circleArcAsCurve(...
%                 [sens_transX,...
%                 sens_transY,...
%                 sensivity_length,...
%                 sensor_pixrot(pixi,1)-pixel_variance,...
%                 sensor_pixrot(pixi,2)+pixel_variance],...
%                 100);
                offset_min = sensor_pixrot(pixi,1)-pixel_variance;
                offset_max = sensor_pixrot(pixi,2)+pixel_variance;
                pix_geom_points = calcPositionOffset(pmax(1), pmax(2), offset_min, sensivity_length);
                pix_geom_points(end+1, :) = calcPositionOffset(pmin(1), pmin(2), offset_max, sensivity_length);
            
            if pixi == pixgeom(2) || sensor_pixvals(pixi+1) == 0 % add last polygon point
                % add sensor origin as last point
%                 pix_geom_points(end+1, :) = [sens_transX, sens_transY];
pix_geom_points(end+1, :) = [pmax(1) ,pmax(2)];
pix_geom_points(end+1, :) = [pmin(1) ,pmin(2)];

                newcone = [conesave; pix_geom_points];
                sensor_pixelcones{count_pixelcones} = newcone;
                
                %paint cone
                sensor_filled_cones{count_pixelcones} = geom2d.fillPolygon(sensor_pixelcones{count_pixelcones}, colors(idx_sensor,:));
                alpha(sensor_filled_cones{count_pixelcones}, 0.3);
                
                count_pixelcones = count_pixelcones +1;
                conesave = [];
                axis([-5 1 -1 5]);
            else
                conesave = [conesave; pix_geom_points];
            end
        end
    end
    
    %             if ~isempty(pixval{idx_sensor,idx_measure}) && pixval{idx_sensor,idx_measure}(pixi,1) > 0
    %                 alpha(sensor_pixelcones{end}, pixval{idx_sensor,idx_measure}(pixi,1)*3);
    %
    %                 if isempty(pixlist) || idx_pixlist == 1 || pixval{idx_sensor,idx_measure}(pixi-1,1) == 0
    %                     pixlist{idx_sensor, idx_pixlist} = pix_geom_points;
    %                     idx_pixlist = idx_pixlist + 1;
    %                 else
    %                     pixlist{idx_sensor, idx_pixlist-1} = [pixlist{idx_sensor, idx_pixlist-1}(1:101, :) ;pix_geom_points];
    %                 end
    %             else
    % %                 alpha(sensor_pixelcones{end}, 0);
    % %             end
    %             %colors(((idx_sensor-1)*rsp.sensor_config.pixgeom(2))+pixi,:));
    %         end
    %     end
    %     plot(reference(1,1), reference(1,2), 'gx')
end
% axis([-5 1 -1 4]);
% % calculate intersections
% intersect_poly = pixlist{1};
% for idx_pixlist = 2:numel(pixlist)
%     intersect_poly = geom2d.intersectPolylines(intersect_poly, pixlist{idx_pixlist});
% end
% geom2d.fillPolygon(pix_geom_points, 'k');
%
% end

