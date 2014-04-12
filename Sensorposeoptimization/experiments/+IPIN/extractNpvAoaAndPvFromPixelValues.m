function [pixel_values_normalized, aoas] = extractNpvAoaAndPvFromPixelValues(init_values, pixel_values_array, config)

%syscal_config = config.Configuration.optimization.syscal_config;
aoa_extractors = config.Configuration.thilo.aoaextractors;
npv_extractors = config.Configuration.thilo.preprocessors;

num_measures = size(pixel_values_array{1}, 2);
num_sensors = size(pixel_values_array, 1);
pixel_values_normalized = cell(num_sensors, num_measures);

waitbar = Tools.Waitbar();
progress = 0;
wbMsg = ['Please Wait, Step 1'];
for idx_init = 1:numel(init_values)
    sensor_values = init_values{idx_init};
    for idx_sensor = 1:numel(init_values{1})
       npv_extractors{idx_sensor}.apply(sensor_values{idx_sensor});
    end
    progress = mod(progress+0.1,1);
    waitbar.update(progress, wbMsg);
end

wbMsg = ['Please Wait, Step 2'];

for idx_sensor = 1:num_sensors
    for idx_measure = 1:num_measures
        for idx_tabs = 1:32
            pixel_values_normalized{idx_sensor, idx_measure} = npv_extractors{idx_sensor}.apply(pixel_values_array{idx_sensor}(:,idx_measure));
        end
    end
    progress = mod(progress+0.1,1);
    waitbar.update(progress, wbMsg);
end

wbMsg = ['Please Wait, Step 3'];

aoas = cell(size(pixel_values_normalized));
for idx_sensor = 1:num_sensors
    temp_aoas = cell(1,num_measures);
    for idx_measure = 1:num_measures
        temp_aoas{idx_measure} = aoa_extractors{idx_sensor}.apply(pixel_values_normalized{idx_sensor, idx_measure});
            progress = mod(progress+0.1,1);
    waitbar.update(progress, wbMsg);
    end
    all_temp_aoas{idx_sensor} = temp_aoas;
end

wbMsg = ['Please Wait, Step 4'];

for idx_sensor = 1:num_sensors
    all_sensor_aoas = all_temp_aoas{idx_sensor};
    for idx_measure = 1:num_measures
        aoas{idx_sensor, idx_measure} = all_sensor_aoas{idx_measure};
    end
        progress = mod(progress+0.1,1);
    waitbar.update(progress, wbMsg);
end

delete(waitbar);