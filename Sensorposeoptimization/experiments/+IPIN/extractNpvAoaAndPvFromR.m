function [pixel_values_normalized, aoas, pixel_values] = extractNpvAoaAndPvFromR(r, sceneFile, thiloConfigFile)
%%
config = Tools.Parser.parseYaml({sceneFile, thiloConfigFile});

%syscal_config = config.Configuration.optimization.syscal_config;
aoa_extractors = config.Configuration.thilo.aoaextractors;
npv_extractors = config.Configuration.thilo.preprocessors;

num_measures = numel(r);
num_sensors = size(r{1,1}.filterInputs.Measurement, 2);
pixel_values = cell(num_sensors, num_measures);
pixel_values_normalized = cell(num_sensors, num_measures);

for idx_sensor = 1:num_sensors
    for idx_measure = 1:num_measures
        pixel_values{idx_sensor, idx_measure} = r{idx_measure}.filterInputs.Measurement{1,idx_sensor};
        pixel_values_normalized{idx_sensor, idx_measure} = npv_extractors{idx_sensor}.apply(pixel_values{idx_sensor, idx_measure});
    end
end


aoas = cell(size(pixel_values_normalized));

parfor idx_sensor = 1:num_sensors
    temp_aoas = cell(1,num_measures);
    for idx_measure = 1:num_measures
        temp_aoas{idx_measure} = aoa_extractors{idx_sensor}.apply(pixel_values_normalized{idx_sensor, idx_measure});
        if mod(idx_measure, 100) == 0
            disp(['Sensor: ' num2str(idx_sensor) ' Measure: ' num2str(idx_measure)]);
        end
    end
    all_temp_aoas{idx_sensor} = temp_aoas;
end

for idx_sensor = 1:num_sensors
    all_sensor_aoas = all_temp_aoas{idx_sensor};
    for idx_measure = 1:num_measures
        aoas{idx_sensor, idx_measure} = all_sensor_aoas{idx_measure};
    end
end