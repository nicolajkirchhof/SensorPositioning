function plotAoas( sensors, aoas )
%PLOTPIXVAL2D Summary of this function goes here
%   Detailed explanation goes here


cla;
hold on;

num_sensors = numel(sensors);

colors = hsv(num_sensors);

%plot sensor positions
for idx_sensor = 1:num_sensors
   geom2d.drawPoint(sensors{idx_sensor}.Position(1:2,1)', 'color', colors(idx_sensor,:));
end
%plot aoa rays
for idx_sensor = 1:num_sensors
    aoas{idx_sensor}
   if aoas{idx_sensor}
       aoa = sensors{idx_sensor}.Orientation(3,1)+aoas{idx_sensor};
    ray = geom2d.createRay(sensors{idx_sensor}.Position(1:2,1)', aoa);
    geom2d.drawLine(ray, 'color', colors(idx_sensor,:));
   end
end

