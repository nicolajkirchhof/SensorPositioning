function [result] =  runCalibrationAutomatically(key, saveToFile, pixel_values_normalized, aoas)

if nargin < 3
    [aoas, pixel_values_normalized] = gatherCalibrationDataSoundGuided(25);
end


    keydate = datestr(now,30);
if nargin  < 1 || isempty(key)
    key = ['K_' keydate];
else
    key = [key '_' keydate];
end
if nargin < 2
    saveToFile = true;
end


dir = mfilename('fullpath');
p = fileparts(dir);
paramDir = [p, '/Parameters/'];

% sceneFile  = [paramDir ,'P1-01-R106.scene.yml'];
% configFile = [paramDir ,'ThILo.config.yml'];
sceneFile  = [paramDir ,'config.yml'];
configFile = [paramDir ,'SqrtOpt.yml'];

% load(data_file); 
config = Tools.Parser.parseYaml( {sceneFile, configFile} );

% 
% if ~exist('aoas')
% [pixel_values_normalized, aoas] = Experimental.extractNpvAoaAndPvFromPixelValues(init_data, pixel_values, config);
% end
%%
syscal_config = config.Configuration.optimization.syscal_config;
syscal_config.pixval_normalized = pixel_values_normalized;
syscal_config.aoas = aoas;
filter = config.Configuration.optimization.filter;
result = filter.filter(syscal_config);


% clear recordList;
if nargin > 1 && saveToFile
    save([key '.mat']);
end
end
