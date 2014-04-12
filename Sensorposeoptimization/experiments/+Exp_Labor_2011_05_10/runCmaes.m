function [result] =  runCmaes(key, saveToFile)

    keydate = datestr(now,30);
if nargin > 1 && saveToFile
    key = ['K_' keydate];
else
    key = [key '_' keydate];
end
if nargin < 2
    saveToFile = false;
end

%%
statistic = [];

%sceneFile  = 'example/matlab/+WPNC_Dresden_2011/+Parameters/IRSE.scene.yaml';
%sceneFile  = 'example/matlab/+WPNC_Dresden_2011/+Parameters/iHome.scene.yaml';
%configFile = 'app/+Exp_Ihome_2011_02_14/SqrtOptLh.config.yaml';

%configFile = 'app/+Exp_Ihome_2011_02_14/SqrtOptAoaJacobian.yaml';
%configFile = 'app/+Exp_Ihome_2011_02_14/SqrtOptAoaCos.yaml';
%configFile = 'app/+Exp_Ihome_2011_02_14/SqrtOptAoaTan.yaml';
% configFile = 'app/+Exp_Labor_2011_05_10/SqrtOptAoaTan.yaml';
configFile = 'app/+Exp_Labor_2011_05_10/CmaesOpt.yaml';


%IHome

%dataFile  ='res/mat/2011_02_14_WPNC_SinglePerson_22_Points.mat';
dataFile  ='res/mat/2011_05_09_Labor_TestDataSet.mat';
%dataFile = '\\ds9\Measurements\Experiments\2011-03-15-WPNC-CricketIR\Scene=run15.txt&Freq=15&Calibrate=2.mat';

%%Simulator
%dataFile  = '\\ds9\Measurements\Experiments\Irsim-Data\A Room With Three Humans - Only Moving Humans Visible\6Two-humans-walk-in-circle-and-quad-in-opposite-directions\Scene=&Freq=15&Calibrate=1.mat';

load(dataFile); 
%config = Experimental.parseYaml({sceneFile, configFile});
config = Experimental.parseYaml({configFile});
%records = 1;
%data   = load(dataFile);
%%
%sensor_pose = Syscal.Parameters.Pose.SensorPose(config.Configuration.sensors.thilo);
%measure_pose = Syscal.Parameters.Pose.MeasurementPose(ref_values, config.Configuration.area);

%syscal_config = Syscal.Parameters.SyscalConfig(measure_pose, sensor_pose, config.Configuration.thilo.sensorModel, config.Configuration.thilo.preprocessors, pixel_values, true );
syscal_config = config.Configuration.optimization.syscal_config;
% syscal_config.measure_pose = ...
%     Filter.Pose.addMeasurePoseLimits( syscal_config.measure_pose, config.Configuration.optimization.position_variance, false );
syscal_config.pixval_normalized = pixel_values_normalized;
syscal_config.pixval = pixel_values;
syscal_config.aoas = aoas;
% syscal_config.plot_figure = figure;


% ropt = Filter.Optimization.RecordedOptimization(config.Configuration.problem);
% ropt.opt_data = syscal_config;
% ropt.plot_fcn = [];
% ropt.plot_fcn = @(x) syscal_config.plot(x);
%ropt.solver = 'fmincon';
%ropt.objective = @Syscal.Detail.OptFcn.likelihood;
%ropt.options = config.Configuration.optimset;


% P = ropt.getProblemStruct;

% [state, fval, exitflag, output ] = lsqnonlin(P);

filter = config.Configuration.optimization.cmaes_optimization;
result = filter.filter(syscal_config);
result.opt_description = syscal_config;

%%
% [state, fval, exitflag, output ] = fmincon(P);
%%
%syscal_config.

% opt = optimset('display', 'iter'...
%   , 'maxfunevals', 2000*numel(scal.stateCurrent) ...
%   , 'maxiter', 2000*numel(scal.stateCurrent) ...
%     , 'plotfcns', @optimplotfval... 
%     , 'tolfun', 1e-8...
%     , 'tolx', 1e-8...
%     , 'Algorithm', 'active-set'...
%     , 'GradObj', 'on'...
% ..., 'Algorithm', 'sqp'...
%     );
% P = "Problem"
% P.objective = fun;
% P.x0 = scal.stateCurrent;
% P.A = [];
% P.b = [];
% P.Aeq = [];
% P.beq = [];
% P.lb = ropt.lb;
% P.ub = sum(scal.stateLimits, 2);
% P.nonlcon = [];
% P.solver = 'fmincon';
% P.options = config.Configuration.optimset;
% 
% [state, fval, exitflag, output ] = fmincon(ropt);


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
if saveToFile
    save([key '.mat']);
end
end
