%%
%selection = [140, 151, 334, 379 515 680 761 947 1004 1255 1275 1501 1792 1878 2005 2054 2353 2398 2799];
selection = [91 141 171 281 341 401 421 481 541 561 591 681 701 801 851 1031 1051 1091 1141 1171 1241];
    cnt = 1;
    pixel_values_normalized = {};
    for id = 1:numel(selection);
        idx_measure = selection(id);
        for idx_sensor = 1:8
            pixel_values_normalized{idx_sensor,cnt} = pixel_values_normalized_all{idx_sensor,idx_measure};
        end
        cnt = cnt + 1;
    end
        

%%
    aoas = cell(1,numel(selection));
for idx_sensor = 1:8

    cnt = 1;
    for idx_measure = 1:numel(selection);
       % idx_measure = selection(id);
        aoas{idx_sensor, cnt} = aoa_extractors{idx_sensor}.apply(pixel_values_normalized{idx_sensor,idx_measure});
%         if mod(idx_measure, 100) == 0
%             disp(['Sensor: ' num2str(idx_sensor) ' Measure: ' num2str(idx_measure)]);
%         end
        cnt = cnt +1;
    end
    
%     all_temp_aoas{idx_sensor} = temp_aoas;
end
%%
cnt = 1;
for idx_sensor = 1:8
    all_sensor_aoas = all_temp_aoas{idx_sensor};
    for idx_measure = 1:numel(all_temp_aoas{1});
        my_aoas{idx_sensor, cnt} = all_sensor_aoas{idx_measure};
        cnt = cnt+1;
    end
end