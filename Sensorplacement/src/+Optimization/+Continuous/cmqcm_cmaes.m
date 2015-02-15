function [ solutions ] = cmqcm_cmaes( cmcq_opt, config )
%START Solves the sensorplacement by approximation of the 
% total number of sensors and an iterative nonlinear search
% input
%   .solution = the found approximate sooption to the spp
% config
%   .timeperiteration = the time in sec that each iteration has to find a valid sooption
%   .maxiterations = the maximum amount of iterations
%   .stopiter = maximum function evaluations before next time check
%%
fmin = 0;
sensors_selected = input.solution.sensors_selected;
solutions = {};
cnt = 0;
%%
while fmin <= 0 && cnt <= config.maxiterations
    
clear cmqm
sensors_selected = sensors_selected(2:end);
cmcq_opt = Optimization.Continuous.prepare_opt(input, sensors_selected);
cmcq_opt.wpn = input.discretization.wpn;

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

opt_fct = @Optimization.Continuous.fitfct.cmqm;
fun_check_stopflag = @(flags) any(strcmpi(flags, 'stoptoresume')|strcmpi(flags, 'manual'));
%%
timer_id = tic;
[opt_vect, fmin, counteval, stopflag, out, bestever ]  = cmaes( opt_fct, opt_vect, [], cmaes_opt );
cmaes_opt.Resume = true;
%%
while toc(timer_id) < maxtime && fun_check_stopflag(stopflag) && fmin > 0
    %%
%     cmaes_opt.StopFunEvals = config.stopfunevals;
    [opt_vect, fmin, counteval, stopflag, out, bestever ]  = cmaes( opt_fct, opt_vect, [], cmaes_opt );
end
%%
sol = input.solution;
sol.sp = Optimization.Continuous.opt_vect_to_sp(opt_vect, cmcq_opt);
sol.fmin = fmin;
sol.conteval = counteval;
sol.stopflag = stopflag;
sol.out = out; 
sol.bestever = bestever;
sol.discretization.num_sensors = size(sol.sp, 2);
sol.sensors_selected = 1:numel(sol.discretization.num_sensors);
fprintf(1, 'Solution with fmin=%g found by %s\n', fmin, stopflag{1});

%%
cnt = cnt + 1;
%%
solutions{end+1} = sol;
end

%% ADD FINAL RUN WITH LAST VALID
sol = solutions{end-1};


%% ONLY CONVERT LAST VALID!!!
% [sol.discretization.sp, sol.discretization.vfovs, sol.discretization.vm] = ...
%     Discretization.Sensorspace.vfov(sol.sp, input.environment, sol.discretization.wpn, input.config.discretization, true); 
% [sol.discretization.spo, sol.discretization.spo_ids] = Discretization.Sensorspace.sameplace(sol.discretization.sp, input.config.discretization.sensor.fov);
% [sol.discretization.sc, sol.discretization.sc_wpn] = Discretization.Sensorspace.sensorcomb(sol.discretization.vm, sol.discretization.spo, input.config.discretization);
% sol.quality = Quality.generate(sol.discretization, Configurations.Quality.diss);

%%
% Discretization.draw(sol.discretization, input.environment);
% Discretization.draw_wpn_max_qualities(sol.discretization, sol.quality);
% axis auto;
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
