function [ sol ] = cmqm_nonlin( cmcq_opt, config )
%%
clear cmqm
fmin = Optimization.Continuous.fitfct.cmqm(cmcq_opt);
opt_vect = [cmcq_opt.x(:); cmcq_opt.phi(:)];
fprintf(1, '\nStarting new opt with initial fitness of %g \n', sum(fmin));

% opt_name = 'lsqnonlin';
opt_name = 'fmincon';
% opt = optimset(opt_name);
opt = optimoptions(opt_name);
opt.Display = 'iter';
% opt.MaxTime = 28800;
opt.UseParallel = config.UseParallel;
% opt.ObjectiveLimit = config.fmin;
if config.verbose
opt.PlotFcns = { @optimplotx; % plots the current point.
@optimplotfunccount; % plots the function count.
@optimplotfval; % plots the function value.
@optimplotresnorm; % plots the norm of the residuals.
@optimplotstepsize; % plots the step size.
@optimplotfirstorderopt}; % plots the first-order optimality measure.
end 
prob.options = opt;
prob.objective = @Optimization.Continuous.fitfct.cmqm;
prob.solver = opt_name;
prob.x0 = opt_vect;
prob.ub = ones(size(opt_vect));
prob.lb = zeros(size(opt_vect));
%%
gs = GlobalSearch;
gs.MaxTime = config.probingtime;
[x,fval,exitflag,output,allmins] = gs.run(prob);
% [xmin,fmin,flag,outpt,allmins]
% [x,fval,exitflag,output] = fmincon(prob);

%%
sol.sp = Optimization.Continuous.opt_vect_to_sp(x, cmcq_opt);
sol.fmin = fval;
sol.stopflag = output.message;
sol.exitflag = exitflag;
sol.output = output;
sol.allmins = allmins;

fprintf(1, 'Solution with fmin=%g found by %s\n', fmin, output.message);
return;
%%
load tmp\conference_room\gco.mat
%%
% profile on;
sol = gco{1, 1};
input = Experiments.Diss.conference_room(sol.num_sp, sol.num_wpn);
input.solution = sol;
config.maxiterations = inf;
config.timeperiteration = 600;
config.stopiter = 500;
config.fmin = 0;
config.UseParallel = false;
%%%
cmcq_opt = Optimization.Continuous.prepare_opt(input, input.solution.discretization.sp);
%%
solutions = Optimization.Continuous.cmqm_nonlin(cmcq_opt, config);
% profile viewer


%%
% function [ sol ] = cmqm_cmaes( cmcq_opt, config )
% %START Solves the sensorplacement by approximation of the 
% % total number of sensors and an iterative nonlinear search
% % input
% %   .solution = the found approximate sooption to the spp
% % config
% %   .timeperiteration = the time in sec that each iteration has to find a valid sooption
% %   .maxiterations = the maximum amount of iterations
% %   .stopiter = maximum function evaluations before next time check
% %%
% clear cmqm
% fmin = Optimization.Continuous.fitfct.cmqm(cmcq_opt);
% 
% cmaes_opt = cmaes('defaults');
% opt_vect = [cmcq_opt.x; cmcq_opt.phi];
% ub = ones(size(opt_vect));
% lb = zeros(size(opt_vect));
% cmaes_opt.LBounds = lb;
% cmaes_opt.UBounds = ub;
% % cmaes_opt.DiffMaxChange = [ones(size(cmcq_opt.x(:)))*1000/cmcq_opt.placeable_edgelenghts_scale; ones(size(cmcq_opt.phi(:)))*deg2rad(10)/(2*pi)];
% maxtime = config.timeperiteration;
% cmaes_opt.StopFitness = config.fmin;
% cmaes_opt.StopIter = config.stopiter;
% cmaes_opt.SaveFilename = config.filename;
% cmaes_opt.Resume = config.resume;
% cmaes_opt.TolFun = 1e-6;
% cmaes_opt.TolHistFun = 1e-7;
% cmaes_opt.TolX = 1e-8;
% cmaes_opt.Restarts = config.restarts;
% 
% opt_fct = @Optimization.Continuous.fitfct.cmqm;
% fun_check_stopflag = @(flags) any(strcmpi(flags, 'stoptoresume')|strcmpi(flags, 'manual'));
% %%
% 
% timer_id = tic;
% if ~cmaes_opt.Resume
%     write_log('Starting new CMAES run, saving in %s', config.filename);
%     [opt_vect, fmin, counteval, stopflag, out, bestever ]  = cmaes( opt_fct, opt_vect, [], cmaes_opt );
%     fprintf(1, '\n Fmin was %g, Counteval was %g, Bestever was %g\n', fmin, counteval, bestever.f);
%     cmaes_opt.Resume = true;
% else
%     bestever.f = 1;
%     stopflag = 'stoptoresume';
%     fmin = 1;
%     write_log('Resuming CMAES run from %s', config.filename);
% end
% %%
% while toc(timer_id) < maxtime && fun_check_stopflag(stopflag) && bestever.f > config.fmin
%     %%
% %     cmaes_opt.StopFunEvals = config.stopfunevals;
%     [opt_vect, fmin, counteval, stopflag, out, bestever ]  = cmaes( opt_fct, opt_vect, [], cmaes_opt );
%     fprintf(1, '\n Fmin was %g, Counteval was %g, Bestever was %g\n', fmin, counteval, bestever.f);
% end
% %%
% % sol = input.solution;
% sol.sp = Optimization.Continuous.opt_vect_to_sp(bestever.x, cmcq_opt);
% sol.fmin = bestever.f;
% sol.conteval = counteval;
% sol.stopflag = stopflag;
% sol.out = out; 
% % sol.bestever = bestever;
% fprintf(1, 'Solution with fmin=%g found by %s\n', fmin, stopflag{1});

%%

return 

%%
