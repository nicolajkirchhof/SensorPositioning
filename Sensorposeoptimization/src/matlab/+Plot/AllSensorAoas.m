function AllSensorAoas(sobjs, aoas, idx_measure, references, axis_limits)
if nargin < 5
    axis_limits = [-4 0 0 4];
end
cla;
color = {'b', 'g', 'r'};
hold on;
axis(axis_limits);

if nargin > 3 && ~isempty(references)
    reference = references(idx_measure, :);
    plot(reference(1,1), reference(1, 2), 'go');
end
calcPositionOffset = @(x, y, phi) [x+cos(phi), y+sin(phi)];
% for idx_measure = 1:syscal_config.NumMeasures
for idx_sensor = 1:numel(sobjs)
    sobj = sobjs{idx_sensor};
    sens_rot = sobj.Orientation(3);
    sens_pos = sobj.Position(1:2)';
 
    
    plot(sens_pos(1,1), sens_pos(1,2), 'ro');
    axis(axis_limits);
    
    aoa = aoas{idx_sensor, idx_measure};
    if ~isempty(aoa)
        for idx_aoa = 1:numel(aoa)
            aoa_pos = calcPositionOffset(sens_pos(1), sens_pos(2), (sens_rot+aoa(idx_aoa)));
            geom2d.drawLine(geom2d.createLine(sens_pos, aoa_pos),'color', color{idx_aoa});
        end
    end
end
% 
%