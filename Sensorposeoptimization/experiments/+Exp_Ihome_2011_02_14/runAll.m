function [records, statistic, config] =  runAll(key, saveToFile)
if nargin  < 1 || isempty(key)
    key = datestr(now,30);
    key = ['K_' key];
end
if nargin < 2
    saveToFile = false;
end


statistic = [];

%sceneFile  = 'example/matlab/+WPNC_Dresden_2011/+Parameters/IRSE.scene.yaml';
%sceneFile  = 'example/matlab/+WPNC_Dresden_2011/+Parameters/iHome.scene.yaml';
configFile = 'app/+Exp_Ihome_2011_02_14/SimSqrtOptLh.config.yaml';
%configFile = 'example/matlab/+WPNC_Dresden_2011/+Parameters/WPNC_Dresden_2011_SMC_Simulator.yaml';

%IHome
%dataFile = '\\ds9\Measurements\Experiments\2011-03-15-WPNC-CricketIR\Scene=run15.txt&Freq=15&Calibrate=2.mat';

%%Simulator
%dataFile  = '\\ds9\Measurements\Experiments\Irsim-Data\A Room With Three Humans - Only Moving Humans Visible\6Two-humans-walk-in-circle-and-quad-in-opposite-directions\Scene=&Freq=15&Calibrate=1.mat';


%%IHOME

%config = Experimental.parseYaml({sceneFile, configFile});
config = Experimental.parseYaml({configFile});
records = 1;
%data   = load(dataFile);

%try
    
%     wb = Tools.Waitbar;
%     
%     recordList= Tools.List;
%     config.Filter.Cartesian2D_SMC_Cricket.reset().eval(data.tsc_cricket, data.tsc_ref, recordList);
%     records.( [key '_cricket'] ) = recordList.toCellArray();
%     statistic = Tools.eval.analyse([key '_cricket'] , records.( [key '_cricket']), statistic);
%     wb.update(1/3,'Evaluating...');
%     
%     recordList = Tools.List;
%     config.Filter.Cartesian2D_SMC_ThILo_And_Cricket.reset().eval(data.tsc_both, data.tsc_ref, recordList);
%     records.( [key '_cricket_and_thilo']) = recordList.toCellArray();
%     statistic = Tools.eval.analyse([key '_cricket_and_thilo'] , records.( [key '_cricket_and_thilo']), statistic);
%     wb.update(2/3,'Evaluating...');
%    
%     recordList = Tools.List;
%     config.Filter.Cartesian2D_SMC_ThILo.reset().eval( data.tsc_abx, data.tsc_ref, recordList);
%     records.( [key '_thilo']) = recordList.toCellArray();
%     statistic = Tools.eval.analyse([key '_thilo'] , records.( [key '_thilo']), statistic);
%     wb.update(3/3,'Evaluating...');
%    
%     
%catch exception
 %   disp(exception.message);
%end

% clear recordList;
if nargout < 2 || saveToFile
    save([key '.mat']);
end
end
