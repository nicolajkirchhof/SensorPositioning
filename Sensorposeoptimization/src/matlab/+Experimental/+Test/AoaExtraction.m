filter = ThILo.Detail.PreProcessor.AoaExtractor;

sobj = ThILo.Detail.Model.Sensor.StCartesian;
filter.Sensor = sobj;

sobj.Orientation = [0; 0; 0];
sobj.Position = [0; 0; 0];
sobj.StateIdx = [1 2];

reference = [4; 5];

pixval_normalized = sobj.evaluate(reference);

aoas = filter.apply(pixval_normalized);

disp(Mltools.rad2deg(atan(reference(2)/reference(1))))
disp(Mltools.rad2deg(aoa))

cla
plot(sobj.Position(1,1), sobj.Position(2,1), 'ro');
hold on;
plot(reference(1,1), reference(2, 1), 'bx');

for i = 1:2:numel(aoas)
    %draw line from x=0 to x=7
    % fast hack for right angle summation
    position(1,1) = 0;
    position(2,1) = tan(sobj.Orientation(3,1)+aoas(1, i)) * (position(1,1)-sobj.Position(1,1)) + sobj.Position(2,1);
    position(1,2) = 6;
    position(2,2) = tan(sobj.Orientation(3,1)+aoas(1, i)) * (position(1,2)-sobj.Position(1,1)) + sobj.Position(2,1);
    line(position(1,:)', position(2,:));
end