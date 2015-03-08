function [ sol ] = cmqm_cmaes( cmcq_opt, config )
%START Solves the sensorplacement by approximation of the 
% total number of sensors and an iterative nonlinear search
% input
%   .solution = the found approximate sooption to the spp
% config
%   .timeperiteration = the time in sec that each iteration has to find a valid sooption
%   .maxiterations = the maximum amount of iterations
%   .stopiter = maximum function evaluations before next time check
%%
clear cmcqm
fmin = Optimization.Continuous.fitfct.cmcqm(cmcq_opt);

cmaes_opt = cmaes('defaults');
opt_vect = [cmcq_opt.x; cmcq_opt.phi];
ub = ones(size(opt_vect));
lb = zeros(size(opt_vect));
cmaes_opt.LBounds = lb;
cmaes_opt.UBounds = ub;
% cmaes_opt.DiffMaxChange = [ones(size(cmcq_opt.x(:)))*1000/cmcq_opt.placeable_edgelenghts_scale; ones(size(cmcq_opt.phi(:)))*deg2rad(10)/(2*pi)];
maxtime = config.timeperiteration;
cmaes_opt.StopFitness = config.fmin;
cmaes_opt.StopIter = config.stopiter;
cmaes_opt.SaveFilename = config.filename;
cmaes_opt.Resume = config.resume;
cmaes_opt.TolFun = 1e-6;
cmaes_opt.TolHistFun = 1e-7;
cmaes_opt.TolX = 1e-8;
cmaes_opt.Restarts = config.restarts;
cmaes_opt.LogFilenamePrefix = config.fileprefix;

opt_fct = @Optimization.Continuous.fitfct.cmcqm;
fun_check_stopflag = @(flags) any(strcmpi(flags, 'stoptoresume')|strcmpi(flags, 'manual'));
%%

timer_id = tic;
if ~cmaes_opt.Resume
    write_log('Starting new CMAES run, saving in %s', config.filename);
    [opt_vect, fmin, counteval, stopflag, out, bestever ]  = cmaes( opt_fct, opt_vect, [], cmaes_opt );
    fprintf(1, '\n Fmin was %g, Counteval was %g, Bestever was %g\n', fmin, counteval, bestever.f);
    cmaes_opt.Resume = true;
else
    bestever.f = 1;
    stopflag = 'stoptoresume';
    fmin = 1;
    write_log('Resuming CMAES run from %s', config.filename);
end
%%
while toc(timer_id) < maxtime && fun_check_stopflag(stopflag) && bestever.f > config.fmin
    %%
%     cmaes_opt.StopFunEvals = config.stopfunevals;
    [opt_vect, fmin, counteval, stopflag, out, bestever ]  = cmaes( opt_fct, opt_vect, [], cmaes_opt );
    fprintf(1, '\n Fmin was %g, Counteval was %g, Bestever was %g\n', fmin, counteval, bestever.f);
end
%%
% sol = input.solution;
sol.sp = Optimization.Continuous.opt_vect_to_sp(bestever.x, cmcq_opt);
sol.fmin = bestever.f;
sol.conteval = counteval;
sol.stopflag = stopflag;
sol.out = out; 
% sol.bestever = bestever;
fprintf(1, 'Solution with fmin=%g found by %s\n', fmin, stopflag{1});

%%

return 

%%
load tmp\conference_room\gco.mat
%%
profile on;
sol = gco{51, 51};
input = Experiments.Diss.conference_room(sol.num_sp, sol.num_wpn);
input.solution = sol;
config.maxiterations = inf;
config.fmin = 0;
config.timeperiteration = 600;
config.stopiter = 500;
config.fileprefix = 'cr';
sp = input.discretization.sp(:, input.solution.sensors_selected);
cmcq_opt = Optimization.Continuous.prepare_opt(input, sp);
config.filename = sprintf('cmaes_tmp%03d.mat', 0);
config.resume = false;
solutions = Optimization.Continuous.cmcqm_cmaes(cmcq_opt, config);
profile viewer
