%load res/mat/sensor.systemcalibration.20110509.mat
load res/mat/sensor.systemcallibration.22points.mat

%% convert to waterfall
for idx_measure = 1:numel(r)
    for idx_sensor = 1:numel(r{idx_measure}.filterInputs.Measurement)
        num_sensors = numel(r{idx_measure}.filterInputs.Measurement);
        columns = (idx_sensor*num_sensors - 7):idx_sensor*num_sensors;
        pixel_values(columns, idx_measure) = r{idx_measure}.filterInputs.Measurement{idx_sensor}(1:8,1);
    end
end
        