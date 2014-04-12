function [timestamps, record ] = gatherCalibrationDataSoundGuided( num_points )
%GATHERCALIBRATIONDATASOUNDGUIDED Summary of this function goes here
%   Detailed explanation goes here

%%
struct data1 data2;
input.num_timestamps = num_points;
input.init_length = 60;
funList = {@gatherCalibrationTimestamps,@gatherCallibrationData};
dataList = {input, []}; % or pass file names

matlabpool open 2
spmd
    labBarrier
    resultList = funList{labindex}();%(dataList{labindex});
end
first = resultList(1);
second = resultList(2);
timestamps = first{1};
record = second{1};
matlabpool close

% end_string = 'Hurray! All Measurements done, wait for post processing';
% disp(end_string);
% tts(end_string);
% [pixel_values_normalized, aoas] = Experimental.extractNpvAoaAndPvFromPixelValues(init_data, pixel_values, config);



function records = gatherCallibrationData()
dir = mfilename('fullpath');
p = fileparts(dir);
% paramDir = [p, '/Parameters/'];
paramDir =  'app/Gui/Parameters/';
% sceneFile  = [paramDir ,'P1-01-R106.scene.yml'];
% configFile = [paramDir ,'ThILo.config.yml'];
sceneFile  = [paramDir ,'config.yml'];
configFile = [paramDir ,'SqrtOpt.yml'];

config = Tools.Parser.parseYaml( {sceneFile, configFile} );
sensors = config.Configuration.sensors.thilo;

%%
connections = { ...
    'tcp://localhost:40009' ...
    'tcp://localhost:40008' ...
    'tcp://localhost:40005' ...
    'tcp://localhost:40006' ...
    'tcp://localhost:40004' ...
    'tcp://localhost:40007' ... %% seems to be defekt
    'tcp://localhost:40011' ...
    'tcp://localhost:40010' ...
    };


%connect
numConnections = numel(connections);
livedatacollection = LiveTest.LSCollection();

for i=1:numConnections
    livedatacollection.addLS( connections{i} );
end

%sort5
% generate mapping from liveseries to sensor
dataIds = livedatacollection.Name; % get names

mapping = [];
for i=1:numel(sensors)
    sensId = sensors{i}.Id;
    j = find( strcmp(dataIds,sensId) );
    if isempty(j)
        continue;
        Warning('Sensor not found');
    end
    mapping(i) = j;
end
livedatacollection.series_ = livedatacollection.series_(mapping);

Filtername =  'DUMP_SensorData_ThILo';
filter =  config.Configuration.Filter.(Filtername).reset();

recordList = Tools.List;

labBarrier;
while (~labProbe)
% for i = 1:100
    tStart = tic;
    [content] = livedatacollection.Data();

    if isempty(content) , break; end;
    %% Preamble
    
    %% Execute code
    
    filter.step(content);
%     tElapsed = toc(tStart);
    
    %minTime = round(min(minTime,(numIterations-cnt)*tElapsed));
        record = Tools.ListItem();
        
        record.Item.iteration  = i;
        record.Item = filter.State;
        record.Item.timestamp = now;
        recordList.push_back( record );
    %% plotting etc.
    %self.poststep();
    
end
records = recordList.toCellArray();
%%


function  timestamps = gatherCalibrationTimestamps(input )
%%
num_timestamps = input.num_timestamps;
init_length = input.init_length;
if nargin < 1
    num_timestamps = 2;
    init_length = 10;
end

stop_string = 'Stop! - make ready for measurement -';
init_string = 'Init! - move fast in quad -';
move_string = 'Measurement Done! - GO, find new position -';

timestamps = [];
labBarrier;
disp(init_string);
tts(init_string);
% init_data = gatherInitData(livedatacollection, 60);
nowTime = @() rem(now,1)*1e5;
update_step_s = 2;
start_time = nowTime();
update_time = rem(now,1)*1e5+update_step_s;
end_time = start_time+init_length;
% cnt = 1;
% data = {};
timestamps(end+1) = now;
while nowTime() < end_time
    %     data{cnt,1} = livedatacollection.Data();
    if nowTime() > update_time
        disp(num2str(end_time - (rem(now,1)*1e5)));
        update_time = nowTime() + update_step_s;
    end
    %     cnt = cnt+1;
end
timestamps(end+1) = now;
% in
% pixel_values = cell(8,1);
% raw_data = {};
% data = cell(8,1);
noOfPoints = 0;
for idx_points = 1:num_timestamps
    disp(stop_string);
    tts(stop_string);
    
    timestamps(end+1) = now;
    pause(1);
    timestamps(end+1) = now;
    % for i = 1:100;
    %     new_data = livedatacollection.Data();
    %     for idx_sensor = 1:8
    %         data{idx_sensor} = [data{idx_sensor}, new_data{idx_sensor}];
    %     end
    % end
    % for idx_sensor = 1:8
    %     pixel_values{idx_sensor}(1:9,end+1) = mean(data{idx_sensor},2);
    %     raw_data{end+1} = data;
    % end
    disp(move_string);
    tts(move_string);
    noOfPoints = noOfPoints + 1;
    counter_str = [num2str(noOfPoints) ' measurements collected'];
    disp(counter_str);
    tts(counter_str);
end
labBroadcast(1, true);

function init_data = gatherInitData(livedatacollection, length)
nowTime = @() rem(now,1)*1e5;
update_step_s = 2;
start_time = nowTime();
update_time = rem(now,1)*1e5+update_step_s;
end_time = start_time+length;
cnt = 1;
data = {};
while nowTime() < end_time
    data{cnt,1} = livedatacollection.Data();
    if nowTime() > update_time
        disp(num2str(end_time - (rem(now,1)*1e5)));
        update_time = nowTime() + update_step_s;
    end
    cnt = cnt+1;
end
init_data = data;


