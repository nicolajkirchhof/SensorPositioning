function SolutionWithAoas( state, aoas, idx_measure )
%SOLUTIONWITHAOAS Summary of this function goes here
%   Detailed explanation goes here
num_sensors = 8;
axis_limits = [-1 7 -1 7];

for idx_sensor = 1:num_sensors
    aoa = aoas{idx_sensor, idx_measure};
    if ~isempty(aoa)
        sobj.Position = [state(idx_sensor*3-2:idx_sensor*3-1,1); 0];
        sobj.Orientation = [0; 0; state(idx_sensor*3)];
        reference = [state(num_sensors*3+idx_measure*2-1:num_sensors*3+idx_measure*2)' 0 0 0 0];
        
        for idx_aoa = 1:numel(aoa)
            
            plot(sobj.Position(1,1), sobj.Position(2,1), 'ro');
            hold on;
            plot(reference(1,1), reference(1, 2), 'go');
            
            
            %draw line from x=0 to x=7
            % fast hack for right angle summation
            position(1,1) = 0;
            position(2,1) = tan(sobj.Orientation(3,1)+aoa(idx_aoa)) * (position(1,1)-sobj.Position(1,1)) + sobj.Position(2,1);
            position(1,2) = 7;
            position(2,2) = tan(sobj.Orientation(3,1)+aoa(idx_aoa)) * (position(1,2)-sobj.Position(1,1)) + sobj.Position(2,1);
            line(position(1,:)', position(2,:));
        end
    end
end
axis(axis_limits);
end

