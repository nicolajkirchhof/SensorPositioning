function [result] =  run(key, saveToFile)



    keydate = datestr(now,30);
if nargin  < 1 || isempty(key)
    key = ['K_' keydate];
else
    key = [key '_' keydate];
end
if nargin < 2
    saveToFile = false;
end


statistic = [];
p = mfilename('fullpath');
p = fileparts(p);
% p = 'app/+Exp_Labor_2011_06_21';
%%
thiloConfigFile = [p '/ThiloConfig.yml'];
configFile = [p '/SqrtOpt.yml'];

dataFile  =[p '/Exp_Labor_2011_06_21.mat'];

config = Tools.Parser.parseYaml({thiloConfigFile, configFile});
load(dataFile); 

syscal_config = config.Configuration.optimization.syscal_config;
%%
syscal_config.pixval_normalized = pixel_values_normalized;
syscal_config.pixval = pixel_values;
syscal_config.aoas = aoas;

filter = config.Configuration.optimization.filter;
result = filter.filter(syscal_config);


% clear recordList;
if nargin > 1 && saveToFile
    save([key '.mat']);
end
end
