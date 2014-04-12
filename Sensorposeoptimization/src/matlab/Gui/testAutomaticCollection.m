soundProduce = @(x) sin(2*pi*x*[0:0.000125:1.0]);
stop_string = {'Stop!', '- hold your position -'};
measure_string = {'Measure!', '- hold your position -'};
init_string = {'Init!', '- move fast in quad -'};
move_string = {'GO!', '- find new position -'};
move_sound = soundProduce(739.99)+soundProduce(440);
stop_sound = soundProduce(554.37)+soundProduce(440);
ctr_string = {'No. Pts:', '0'};
pixel_values = cell(8,1);
raw_data = {};
data = cell(8,1);
noOfPoints = 0;
for idx_points = 1:num_points
    disp(stop_string);
    wavplay(stop_sound);
    pause(1);
    disp(measure_string);

for i = 1:100;
    new_data = livedatacollection.Data();
    for idx_sensor = 1:8
        data{idx_sensor} = [data{idx_sensor}, new_data{idx_sensor}];
    end
end
for idx_sensor = 1:8
    pixel_values{idx_sensor}(1:9,end+1) = mean(data{idx_sensor},2);
    raw_data{end+1} = data;
end
    noOfPoints = noOfPoints + 1;
    ctr_string{2} = num2str(noOfPoints);
    disp(ctr_string);
    disp(move_string);
    wavplay(move_sound);
    pause(3);
end