classdef PlotSensorState < IPlotState
    properties
        h
        hold
    end
    
    methods
        function eval( obj, pose )
            obj.activate();
            fov_2 = mltools.deg2rad(24);
            length = 3;
            nsensors = size(pose,1);
            colors = hsv(nsensors);
            
            for i = 1:nsensors
                pix_geom_points = geom2d.circleArcAsCurve(...
                    [pose(i,1)...
                    ,pose(i,2)...
                    ,length...
                    ,pose(i,3)-fov_2...
                    ,pose(i,3)+fov_2]...
                    ,100);
                % add sensor origin as last point
                pix_geom_points(end+1, :) = [pose(i,1), pose(i,2)]; %#ok<AGROW>
                
                
                sensors{i} = geom2d.fillPolygon(pix_geom_points,...
                    colors(i,:));
                alpha(sensors{end}, 0.3);
                %colors(((i-1)*rsp.sensor_config.pixgeom(2))+pixi,:));
            end
            
        end
    end
end