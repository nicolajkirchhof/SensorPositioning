function sensor = tpl()
%% TPL generates the envelope to store the sensor data

sensor = Configurations.Sensor.generic();
sensor.distance = [0 7000];
sensor.fov = 48;
sensor.directional = deg2rad([3 sensor.fov]);
sensor.type = Configurations.Sensor.get_types().tpl;
