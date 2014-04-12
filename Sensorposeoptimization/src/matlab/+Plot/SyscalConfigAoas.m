function SyscalConfigAoas(syscal_config, idx_measure)
cla;
% for idx_measure = 1:syscal_config.NumMeasures
for idx_sensor = 1:syscal_config.NumSensors
    sobj = syscal_config.sensor_objects{idx_sensor};
    
    aoas = syscal_config.aoas{idx_sensor, idx_measure};
    reference = syscal_config.measure_pose.reference(idx_measure, :);
    
    plot(sobj.Position(1,1), sobj.Position(2,1), 'ro');
    hold on;
    plot(reference(1,1), reference(1, 2), 'go');
    
    for i = 1:2:numel(aoas)
        %draw line from x=0 to x=7
        % fast hack for right angle summation
        position(1,1) = 0;
        position(2,1) = tan(sobj.Orientation(3,1)+aoas(1, i)) * (position(1,1)-sobj.Position(1,1)) + sobj.Position(2,1);
        position(1,2) = 6;
        position(2,2) = tan(sobj.Orientation(3,1)+aoas(1, i)) * (position(1,2)-sobj.Position(1,1)) + sobj.Position(2,1);
        line(position(1,:)', position(2,:));
    end
end
axis([-1 7 -1 7]);

