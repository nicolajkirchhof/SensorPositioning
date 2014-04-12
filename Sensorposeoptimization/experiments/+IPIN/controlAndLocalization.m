function [ data_store ] = controlAndLocalization( input )
%CALIBRATIONCOORDINATOR Summary of this function goes here
%   Detailed explanation goes here
%
% collects the measurements and sends them to the calibrator
% tts = @(x) x;

stop_string = 'Stop! - make ready for measurement -';
init_string = 'Init! - move fast in quad -';
move_string = 'Measurement Done! - GO, find new position -';

% 1. wait for timestamp
% 2. collect normalized pixel values
% 3. push to calibrator
% 4. pull calibration
% 5. start localization
% 6. continue randomly pushing data to calibrator

config = input.config;
idx_sdr = input.idx_sdr;
idx_cw = input.idx_cw;
debug = input.debug;
info = input.info;
init_length = input.init_length;
protocol = input.protocol;
debug = input.debug;
timestamps = [];


% INITIALIZATION
labBarrier;
disp(init_string);
tts(init_string);
nowTime = @() rem(now,1)*1e5;
update_step_s = 2;
start_time = nowTime();
update_time = rem(now,1)*1e5+update_step_s;
end_time = start_time+init_length;
% cnt = 1;
% data = {};
% timestamps(end+1) = now;
while nowTime() < end_time
    %     data{cnt,1} = livedatacollection.Data();
    if nowTime() > update_time
        disp(num2str(end_time - (rem(now,1)*1e5)));
        update_time = nowTime() + update_step_s;
    end
    %     cnt = cnt+1;
end
% timestamps(end+1) = now;
% in
% pixel_values = cell(8,1);
% raw_data = {};
% data = cell(8,1);
info('init_done');
data_store = {};
noOfPoints = 0;
num_avg_measures = 150;
is_calibration_done = labReceive(idx_cw, protocol.action.calibration_control)==protocol.command.stop;
while (~is_calibration_done)
    disp(stop_string);
    tts(stop_string);
    
    info('start polling');
    labSend(protocol.command.start, idx_sdr, protocol.action.data_polling);
    data_sum = zeros(9,8);
%     timestamps(end+1) = now;
    for idx_measure = 1:num_avg_measures
        data = labReceive(idx_sdr);
        data_store{noOfPoints+1, idx_measure} = data;
        if ~isempty(data)
            data_sum = data_sum+labReceive(idx_sdr);
        end
        debug('data received');
    end
    
    info('stop polling');
    labSend(protocol.command.stop, idx_sdr, protocol.action.data_polling);
    labSend(data_sum./num_avg_measures, idx_cw);
%     timestamps(end+1) = now;
            
    disp(move_string);
    tts(move_string);
    noOfPoints = noOfPoints + 1;
%     aoas{noOfPoints} = labReceive(idx_cw, protocol.action.lab_control);
%     counter_str = [num2str(noOfPoints) ' measurements collected'];
%     debug(counter_str);
    %tts(counter_str);
    is_calibration_done = labReceive(idx_cw, protocol.action.calibration_control)==protocol.command.stop;
end
info('initial calibration done');
labSend(protocol.command.stop, idx_sdr, protocol.action.lab_control)

calibration = labReceive(idx_cw, protocol.action.data_transmission);
info('received calibration');
state_single_sensor = calibration.opt_description.double2singleSensorState(calibration.state);

Filtername =  'Cartesian2D_SMC_ThILo_Live';
filter =  config.Configuration.Filter.(Filtername).reset();
sensors = config.Configuration.sensors.thilo;

for idx_sensor = 1:numel(sensors)
    idx_state = idx_sensor*3-2;
    filter.filter.Items{2}.Items{idx_sensor}.SensorModel.Position(1,1) = state_single_sensor(idx_state);
    filter.filter.Items{2}.Items{idx_sensor}.SensorModel.Position(2,1) = state_single_sensor(idx_state+1);
    filter.filter.Items{2}.Items{idx_sensor}.SensorModel.Orientation(3,1) = state_single_sensor(idx_state+2);
end

info('applied inital calibration to filter');
labSend(protocol.command.start, idx_sdr, protocol.action.localization_control);
num_iterations  = 1000;
for i = 1:num_iterations
    data = labReceive(idx_sdr, protocol.action.data_transmission);
    filter.step(data);
    labSend(filter.State, idx_sdr, protocol.action.data_transmission);
    if i < num_iterations
        labSend(protocol.command.continue, idx_sdr, protocol.action.localization_control);
    else
        labSend(protocol.command.stop, idx_sdr, protocol.action.localization_control);
    end
    disp(i);
end


end

