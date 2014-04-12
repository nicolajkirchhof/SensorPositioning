dir = mfilename('fullpath');
p = fileparts(dir);
% paramDir = [p, '/Parameters/'];
paramDir =  'app/+Experimental/+IPIN/Parameters/';
% sceneFile  = [paramDir ,'P1-01-R106.scene.yml'];
% configFile = [paramDir ,'ThILo.config.yml'];
sceneFile  = [paramDir ,'config.yml'];
configFile = [paramDir ,'SqrtOpt.yml'];

config = Tools.Parser.parseYaml( {sceneFile, configFile} );

%
import Experimental.IPIN.*

num_points = 5;
init_length = 15;

input.idx_cal = 1;
input.idx_sdr = 2;
input.idx_cw = 3;
input.config = config;
input.init_length = init_length;
% input.debug = @(x) disp(x);
input.debug = @(x) x;
input.info = @(x) disp(x);

input.protocol.command.stop = 0;
input.protocol.command.start = 1;
input.protocol.command.continue = 2;
input.protocol.action.lab_control = 0;
input.protocol.action.data_polling = 1;
input.protocol.action.data_transmission = 2;
input.protocol.action.calibration_control = 3;
input.protocol.action.localization_control = 4;

funList = {@controlAndLocalization,@sensorDataReceiver, @calibrationWorker};
% funList = {@sensorDataReceiver, @sdrTest};
% dataList = {input_rec, input_cc}; % or pass file names
%%
isOpen = matlabpool('size') > 0;
if isOpen, matlabpool close, end
matlabpool open 3
spmd
    resultList = funList{labindex}(input);%(dataList{labindex});
end
%%      
matlabpool close
%%
state = Experimental.IPIN.runCalibration(timestamps, record, config);

