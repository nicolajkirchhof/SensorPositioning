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
clear cmqm
fmin = Optimization.Continuous.fitfct.cmqm(cmcq_opt);

cmaes_opt = cmaes('defaults');
opt_vect = [cmcq_opt.x; cmcq_opt.phi];
ub = ones(size(opt_vect))-eps;
lb = zeros(size(opt_vect));
cmaes_opt.LBounds = lb;
cmaes_opt.UBounds = ub;
maxtime = config.timeperiteration;
cmaes_opt.StopFitness = 0;
cmaes_opt.StopIter = config.stopiter;
cmaes_opt.SaveFilename = config.filename;
cmaes_opt.Resume = config.resume;

opt_fct = @Optimization.Continuous.fitfct.cmqm;
fun_check_stopflag = @(flags) any(strcmpi(flags, 'stoptoresume')|strcmpi(flags, 'manual'));
%%

timer_id = tic;
if ~cmaes_opt.Resume
    write_log('Starting new CMAES run, saving in %s', config.filename);
    [opt_vect, fmin, counteval, stopflag, out, bestever ]  = cmaes( opt_fct, opt_vect, [], cmaes_opt );
else
    write_log('Resuming CMAES run from %s', config.filename);
end
%%
while toc(timer_id) < maxtime && fun_check_stopflag(stopflag) && fmin > 0
    %%
%     cmaes_opt.StopFunEvals = config.stopfunevals;
    [opt_vect, fmin, counteval, stopflag, out, bestever ]  = cmaes( opt_fct, opt_vect, [], cmaes_opt );
end
%%
% sol = input.solution;
sol.sp = Optimization.Continuous.opt_vect_to_sp(opt_vect, cmcq_opt);
sol.fmin = fmin;
sol.conteval = counteval;
sol.stopflag = stopflag;
sol.out = out; 
sol.bestever = bestever;
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
config.timeperiteration = 1800;
config.stopiter = 500;
solutions = Optimization.Continuous.cmqm_cmaes_it(input, config);
profile viewer
