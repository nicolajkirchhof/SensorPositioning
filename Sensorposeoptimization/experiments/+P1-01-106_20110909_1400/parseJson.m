config = Tools.Parser.parseYaml({'ThiloConfig.yml'});
%
for i = 1:8
    ids{i} = config.Configuration.sensors.thilo{i}.Id;
end

%% Parse from file

fName = 'nico.json';
%fName = 'tst.json';

fid = fopen(fName,'rt');
%inString = fscanf(fid,'%c');
inString = textscan(fid, '%s', 'delimiter', sprintf('\n'));
fclose(fid);
inString = inString{1};
%%
%[tst{1} rem] = strtok(inString, char(10));
%
%idx = 2;
%while numel(rem) > 0
%    [tst{idx} rem] = strtok(rem, char(10));
%    idx = idx +1;
%end
%% sort
import p_json.*
pixel_values_multilist = cell(8,1);
pixel_values_json = cell(8,1);
for i = 1:8; pixel_values_multilist{i} = {}; end;
for i = 1:8; pixel_values_json{i} = {}; end;


for idx_pv = 1:numel(inString)
    data = p_json(inString{idx_pv});
    idx_sensor = find(strcmp(ids, data.u));
    temp_data = p_json(data.v);
    
    fields_ = fields(temp_data);
    no_fields = numel(fields_);
    for it_field=1:no_fields
        key = fields_{it_field};
        if iscell( temp_data.(key)) && all(cellfun(@isnumeric, temp_data.(key)))
            temp_data.(key) = cell2mat( temp_data.(key) );
        end
    end
    pixel_values_multilist{idx_sensor}{end+1} = temp_data.vp;
    pixel_values_json{idx_sensor}{end+1} = temp_data;
end

%%

aoa_extractors = config.Configuration.thilo.aoaextractors;
npv_extractors = config.Configuration.thilo.preprocessors;

num_measures = 2970;
num_sensors = 8;
pixel_values = cell(num_sensors, num_measures);
pixel_values_normalized = cell(num_sensors, num_measures);

for idx_sensor = 1:num_sensors
    for idx_measure = 1:num_measures
        %pixel_values{idx_sensor, idx_measure} = [pixel_values_multilist{idx_sensor}{idx_measure}{:}]';
        %pixel_values_normalized{idx_sensor, idx_measure} = npv_extractors{idx_sensor}.apply(pixel_values{idx_sensor, idx_measure});
        pixel_values_normalized{idx_sensor, idx_measure} = npv_extractors{idx_sensor}.apply(pixel_values_json{idx_sensor}{idx_measure});
    end
end

%%
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
