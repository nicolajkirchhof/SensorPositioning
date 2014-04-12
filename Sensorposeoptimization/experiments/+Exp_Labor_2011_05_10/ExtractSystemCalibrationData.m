%% Extract System Calibration Data from feburary
load res/mat/sensor.systemcallibration.22points.mat

% convert to large array
for idx_measure = 1:numel(r)
    for idx_sensor = 1:numel(r{idx_measure}.filterInputs.Measurement)
        num_sensors = numel(r{idx_measure}.filterInputs.Measurement);
        columns = (idx_sensor*num_sensors - 7):idx_sensor*num_sensors;
        pixel_values_all_measurements(columns, idx_measure) = r{idx_measure}.filterInputs.Measurement{idx_sensor}(1:8,1);
    end
end
%%% Substract Offset
idx_offset = [ 1 2000 nan nan
1 1500 3280 3820
1 1500 2660 3800
1 1200 2500 3900
1 1000 2300 4000
1800 4100 nan nan
1830 5000 nan nan
1500 5000 nan nan
1 4000 nan nan
1 4000 nan nan
1 4000 nan nan
1 4000 nan nan
1 3300 nan nan
1 3300 nan nan
1 2500 4700 5100
1 2100 4600 5100
1 1000 2800 3500
1 600 2100 3600
2050 3700 nan nan
800 3600 nan nan
1 3800 nan nan 
1 4000 nan nan
1 4000 nan nan
1 4000 nan nan
1 3000 4200 5000
1 3000 4000 5000
1 3000 4000 5000
1 2600 4000 5000
1 2500 4000 5000
1 2000 4000 5000
1 1800 4000 5000
1 1000 4000 5100
1 2300 4600 5100
1 2300 4650 5050
1 2600 nan nan
1 2600 3900 4400
1 3000 3900 4500
1 3000 3900 4500
1 3000 3900 5000
1 3000 3900 5000
1 5000 nan nan
2700 5000 nan nan
2550 5000 nan nan
2700 5000 nan nan
800 1200 3250 5000
1 1400 3250 4100
1 1600 4350 5220
1 2350 4550 5170
1 1000 2300 3700
1 1000 2750 3550
1 1050 2750 3550
1 1900 4000 5000
1 1900 4000 5000
1 1900 4000 5000
1 1900 4000 5000
1 2800 4000 5000
2000 5000 nan nan
2000 5000 nan nan
2000 5000 nan nan
2000 4000 4500 5150
2000 4000 4400 5000
1 1000 2000 4000
1 1000 2200 3800
1 1100 2050 3650 ];

for idx_measures = 1:size(idx_offset, 1)
    flt = [idx_offset(idx_measures, 1):idx_offset(idx_measures, 2)];
    if ~isnan(idx_offset(idx_measures, 3))
        flt_1 = [idx_offset(idx_measures, 3):idx_offset(idx_measures, 4)];
        flt = [flt, flt_1];
    end
%     plot(pixel_values_all_measurements(idx_measures,flt));
    offset(idx_measures,1) = mean(pixel_values_all_measurements(idx_measures,flt));
%     pause
end
%%%


% 
% for i = 1:size(pixel_values_all_measurements, 1)
% plot(pixel_values_all_measurements(i,:));
% disp(i);
% pause;
% end
% 
% 
% 
% idx_cal = pixel_values_all_measurements < 0;
% 
% for i = 1:size(pixel_values_all_measurements, 1)
%     offset(i,1) = mean(pixel_values_all_measurements(i, idx_cal(i,:)));
% end
%%%
pixel_values_all_measurements_calibrated = pixel_values_all_measurements-repmat(offset, 1, size(pixel_values_all_measurements, 2));

%%%
offset = 0;
ref_values = {};
num_sensors = 8;

position_idx = ...
    [ 300 600 27
      750 1000 26
    1150 1400 17
    1500 1700 18
    1750 1950 5
    2030 2210 16
    2260 2460 15
    2520 2680 4
    2740 2900 3
    2970 3170 14
    3230 3380 13
    3420 3560 12
    3610 3745 2
    3790 3930 1
    3970 4100 6
    4140 4290 19
    4350 4470 7
    4500 4620 8
    4650 4760 9
    4790 4890 24
    4940 5060 23
    5100 5220 22 ];


pixel_values_extracted = {};
for idx_measure = 1:size(position_idx, 1)
    for idx_sensor = 1:num_sensors
        idx_start = (idx_sensor-1)*num_sensors+1;
        idx_end = idx_start + 7;
        idx_mesaure_start = position_idx(idx_measure, 1);
        idx_mesaure_end = position_idx(idx_measure, 2);
        pixel_values_extracted{idx_sensor, idx_measure} = mean(pixel_values_all_measurements_calibrated(idx_start:idx_end, idx_mesaure_start:idx_mesaure_end),2);
    end
end

sensorPositions = 'app/+Exp_Labor_2011_05_10/sensorPositions.yaml';
refs = Experimental.parseYaml({sensorPositions});

ref_values = zeros(size(position_idx, 1), 6);
for idx_measure = 1:size(position_idx, 1)
    idx_ref = position_idx(idx_measure, 3);
    ref_values(idx_measure, 1:2) = refs.ReferencePoints{idx_ref}.referencepoint.pos;
end


%%
configFile = 'app/+Exp_Labor_2011_05_10/SqrtOptAoaTan.yaml';

config = Experimental.parseYaml({configFile});
%%
[ aoas, pixel_values_normalized, position_estimates ] = config.Configuration.optimization.preprocessor.apply( pixel_values_extracted,  ref_values );



