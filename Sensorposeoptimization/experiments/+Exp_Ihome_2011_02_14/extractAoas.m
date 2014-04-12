function [state, fval, exitflag, output] =  run(key, saveToFile)
if nargin  < 1 || isempty(key)
    key = datestr(now,30);
    key = ['K_' key];
end
if nargin < 2
    saveToFile = false;
end

%%
%sceneFile  = 'example/matlab/+WPNC_Dresden_2011/+Parameters/IRSE.scene.yaml';
%sceneFile  = 'example/matlab/+WPNC_Dresden_2011/+Parameters/iHome.scene.yaml';
%configFile = 'app/+Exp_Ihome_2011_02_14/SqrtOptLh.config.yaml';

%configFile = 'app/+Exp_Ihome_2011_02_14/SqrtOptAoaJacobian.yaml';
%configFile = 'app/+Exp_Ihome_2011_02_14/SqrtOptAoaCos.yaml';
configFile = 'app/+Exp_Ihome_2011_02_14/ExtractAoaConfig.yaml';



%IHome

dataFile  ='res/mat/2011_02_14_WPNC_SinglePerson_22_Points.mat';
%dataFile = '\\ds9\Measurements\Experiments\2011-03-15-WPNC-CricketIR\Scene=run15.txt&Freq=15&Calibrate=2.mat';

%%Simulator
%dataFile  = '\\ds9\Measurements\Experiments\Irsim-Data\A Room With Three Humans - Only Moving Humans Visible\6Two-humans-walk-in-circle-and-quad-in-opposite-directions\Scene=&Freq=15&Calibrate=1.mat';

load(dataFile);
%config = Experimental.parseYaml({sceneFile, configFile});
config = Experimental.parseYaml({configFile});
%records = 1;
%data   = load(dataFile);

%syscal_config = Syscal.Parameters.SyscalConfig(measure_pose, sensor_pose, config.Configuration.thilo.sensorModel, config.Configuration.thilo.preprocessors, pixel_values, true );



syscal_config = config.Configuration.optimization.syscal_config;
syscal_config.measure_pose.Reference = ref_values;
syscal_config.pixval_normalized = pixel_values_normed;
syscal_config.pixval = pixel_values;
syscal_config.aoas = aoas;
syscal_config.plot_figure = figure;


ropt = Filter.Optimization.RecordedOptimization(config.Configuration.problem);
ropt.opt_data = syscal_config;
%ropt.solver = 'fmincon';
%ropt.objective = @Syscal.Detail.OptFcn.likelihood;
%ropt.options = config.Configuration.optimset;


P = ropt.getProblemStruct;


[state, fval, exitflag, output ] = lsqnonlin(P);

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
if nargout < 2 || saveToFile
    save([key '.mat']);
end
end
