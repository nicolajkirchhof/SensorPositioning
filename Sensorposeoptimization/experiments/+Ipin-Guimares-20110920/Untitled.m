aoanew = cell(size(pvn));

for idx_sensor = 1:num_sensors
    temp_aoas = cell(1,1);
    for idx_measure = 1:1
        temp_aoas{idx_measure} = aoa_extractors{idx_sensor}.apply(pvn{idx_sensor});
        if mod(idx_measure, 100) == 0
            disp(['Sensor: ' num2str(idx_sensor) ' Measure: ' num2str(idx_measure)]);
        end
    end
    all_temp_aoas{idx_sensor} = temp_aoas;
end