function sensor = tpl()
%% TPL generates the envelope to store the sensor data

sensor = Configurations.Sensor.generic();
sensor.distance = [0 7000];
sensor.fov = 48;
sensor.directional = deg2rad([3 sensor.fov]);
sensor.area = [10000 7000^2/2];
sensor.type = Configurations.Sensor.get_types().tpl;
sensor.distance_optimal = [3000];
