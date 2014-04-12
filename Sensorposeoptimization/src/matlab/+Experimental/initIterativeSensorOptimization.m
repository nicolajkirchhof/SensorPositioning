function S = initIterativeSensorOptimization( syscal_config )
%INITITERATIVESENSOROPTIMIZATION Summary of this function goes here
%   Detailed explanation goes here
    for idx_sensor = 1:syscal_config.NumSensors
        pmin = syscal_config.sensor_pose.lb(idx_sensor*2, 1:2);
        pmax = syscal_config.sensor_pose.ub(idx_sensor*2, 1:2);
        S.sensorAoaBounds{idx_sensor*2-1} = [syscal_config.sensor_pose.lb((idx_sensor*2)-1, 6), syscal_config.sensor_pose.ub((idx_sensor*2)-1, 6)];
        S.sensorAoaBounds{idx_sensor*2} = [syscal_config.sensor_pose.lb(idx_sensor*2, 6), syscal_config.sensor_pose.ub(idx_sensor*2, 6)];
        S.sensorBoundPolygons{idx_sensor} =  [pmin; pmax(1), pmin(2); pmax; pmin(1), pmax(2); pmin];
        S.sensorBoundPolygonCenters{idx_sensor} = geom2d.polygonCentroid(S.sensorBoundPolygons{idx_sensor});
        %         geom2d.drawPolygon(S.sensorBoundPolygons{idx_sensor});
    end

end

