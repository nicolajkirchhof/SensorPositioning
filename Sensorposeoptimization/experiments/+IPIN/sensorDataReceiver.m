function records = sensorDataReceiver(input)

% data_provider = input.data_provider;
config = input.config;
idx_cal = input.idx_cal;
protocol = input.protocol;
debug = input.debug;
info = input.info;
record_localization = true;
debug('Starting Lab');


data_format = 0;
start_receiving = 1;
stop_receiving = 0;
%%
Filtername =  'DUMP_SensorData_ThILo';
filter =  config.Configuration.Filter.(Filtername).reset();

sensors = config.Configuration.sensors.thilo;
connections = { ...
    'tcp://ds42.it.irf.tu-dortmund.de:40009' ...
    'tcp://ds42.it.irf.tu-dortmund.de:40008' ...
    'tcp://ds42.it.irf.tu-dortmund.de:40005' ...
    'tcp://ds42.it.irf.tu-dortmund.de:40006' ...
    'tcp://ds42.it.irf.tu-dortmund.de:40004' ...
    'tcp://ds42.it.irf.tu-dortmund.de:40007' ...
    'tcp://ds42.it.irf.tu-dortmund.de:40011' ...
    'tcp://ds42.it.irf.tu-dortmund.de:40010' ...
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
%%
recordList = Tools.List;
send_data = false;
%%
labBarrier;
while (~labProbe(idx_cal, protocol.action.lab_control))
    % for i = 1:100
    %     tStart = tic;
    [content] = livedatacollection.Data();
    
    if isempty(content) , break; end;
    %% Preamble
    
    %% Execute code
    
    filter.step(content);
    %     tElapsed = toc(tStart);
    
    %minTime = round(min(minTime,(numIterations-cnt)*tElapsed));
    if labProbe(idx_cal, protocol.action.data_polling)
        send_data = logical(labReceive(idx_cal, protocol.action.data_polling));
        info('Start sending ');
    end
    if send_data
        record = Tools.ListItem();
        
        record.Item.iteration  = i;
        record.Item = filter.State;
        record.Item.timestamp = now;
        debug('Sending data');
        labSend([record.Item.filterInputs.MeasurementPreprocessed{:}], idx_cal);
        recordList.push_back( record );
    end
    %% plotting etc.
    %self.poststep();
end
labReceive(idx_cal, protocol.action.lab_control)
info('left while loop');
%% Publisher
zmq_context = ZMQ.Context();
zmq_address = 'tcp://*:55555';
zmq_socket  = zmq_context.socket(ZMQ.Defs.ZMQ_PUB);
zmq_socket.bind(zmq_address);
info('publisher created');
%%
    function zmq_send_matrix(matrix, flag)
        %%numDimenstions %% arrayOfDimensions
        %%dim1
        %%dim2
        %%data
        nodims = ndims(matrix);
        nodims = uint8(nodims);
        rc = zmq_socket.send(nodims, ZMQ.Defs.ZMQ_SNDMORE);
        assert(rc==0);
        for it=1:nodims
            rc = zmq_socket.send( uint32(size(matrix,it)), ZMQ.Defs.ZMQ_SNDMORE);
            assert(rc==0);
        end
        %%serialize
        rc = zmq_socket.send(double(matrix(:)), flag);
        assert(rc==0);
    end
%%
is_next_step = labReceive(idx_cal, protocol.action.localization_control)==protocol.command.start;

if is_next_step
    labSend(livedatacollection.Data(), idx_cal, protocol.action.data_transmission);
    info('send initial data to cal');
    filter_state = labReceive(idx_cal, protocol.action.data_transmission);
    info('received initial position');
    is_next_step = labReceive(idx_cal, protocol.action.localization_control)==protocol.command.continue;
    
    while is_next_step
        
        labSend(livedatacollection.Data(), idx_cal, protocol.action.data_transmission);
        
        timestamp = uint64(0);
        
        if record_localization
            record = Tools.ListItem();
            
            record.Item.iteration  = i;
            record.Item = filter_state;
            record.Item.timestamp = now;
            %debug('Sending data');
            %labSend([record.Item.filterInputs.MeasurementPreprocessed{:}]./100, idx_cal);
            recordList.push_back( record );
        end
        
        %column key
        rc = zmq_socket.send('P1/01/116/ThILo',ZMQ.Defs.ZMQ_SNDMORE);
        %row key
        rc = zmq_socket.send('Position',ZMQ.Defs.ZMQ_SNDMORE);
        %timestamp
        rc = zmq_socket.send(timestamp,ZMQ.Defs.ZMQ_SNDMORE);
        %data
        
        zmq_send_matrix(filter_state.estimate.State, 0);
        %disp(filter.State.estimate.State);
        
        filter_state = labReceive(idx_cal, protocol.action.data_transmission);
        is_next_step = labReceive(idx_cal, protocol.action.localization_control)==protocol.command.continue;
    end
end

records = recordList.toCellArray();
end