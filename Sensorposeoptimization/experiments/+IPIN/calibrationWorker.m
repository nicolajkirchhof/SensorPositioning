function [ all_calibrations, all_aoas ] = calibrationWorker( input )
%CALIBRATOR Summary of this function goes here
%   Detailed explanation goes here

% 1. wait for input data
% 2. count equations
% 3. start calibrating when #equations > #state_variables

config = input.config;
aoa_extractors = config.Configuration.thilo.aoaextractors;
idx_cal = input.idx_cal;
debug = input.debug;
info = input.info;
protocol = input.protocol;

num_sensors = numel(config.Configuration.sensors.thilo);
sensors = config.Configuration.sensors.thilo;
cnt_states = numel(config.Configuration.sensors.thilo)*2; %double sensors
variance_position = config.Configuration.sensors.thilo{3}.PositionVariance;
variance_orientation = config.Configuration.sensors.thilo{3}.OrientationVariance;
syscal_config = config.Configuration.optimization.syscal_config;
is_calibration_found = false;
cnt_calibrations = 0;
all_aoas = {};
all_calibrations = {};
labBarrier;
while ~is_calibration_found
    cnt_eqn = 0;
    received_data = {};
    aoas = cell(8,1);
    calibration_data = {};
    cnt = 1;
    
    while cnt_eqn <= cnt_states
        labSend(protocol.command.continue, idx_cal, protocol.action.calibration_control);
        received_data = labReceive(idx_cal);
        
        for idx_sensor = 1:num_sensors
            if any(received_data(1:8,idx_sensor))
                aoas{idx_sensor, cnt} = aoa_extractors{idx_sensor}.apply(received_data(1:8,idx_sensor));
            end
        end
        %[aoas{:, cnt}];
        % Experimental.IPIN.plotAoas(sensors, aoas(:,cnt));
%         labSend(aoas(:,cnt), idx_cal, protocol.action.lab_control);
        equations = numel([aoas{:, cnt}]);
        %     disp(numel(received_data));
        %     data_cleared = received_data(1:8,:);
        %     equations = sum(any(data_cleared,1));
        
        if equations > 2
            cnt_eqn = cnt_eqn+equations;
            cnt_states = cnt_states + 2;
            cnt = cnt+1;
        end
        fprintf(1, 'eq = %d, sc = %d\n', cnt_eqn, cnt_states);
    end
    cnt_calibrations = cnt_calibrations + 1;
    labSend(protocol.command.stop, idx_cal, protocol.action.calibration_control);
    %%
    syscal_config.aoas = aoas;
    filter = config.Configuration.optimization.filter;
    calibration = filter.filter(syscal_config);
    all_calibrations{end+1} = calibration;
    
    if mod(cnt_calibrations, 3)
        syscal_config = readjustSensorPose(calibration, syscal_config);
    end
    %%
    labSend(calibration, idx_cal, protocol.action.data_transmission);
    all_aoas{cnt_calibrations} = aoas;
    is_calibration_found = true;
    
end


function syscal_config = readjustSensorPose(calibration, syscal_config)

%TO BE IMPLEMENTED


