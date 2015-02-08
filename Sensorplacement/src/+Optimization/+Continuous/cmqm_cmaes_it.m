function [ solutions ] = cmqm_cmaes_it( input, config )
%START Solves the sensorplacement by approximation of the 
% total number of sensors and an iterative nonlinear search
% config
%   .sooption = the found approximate sooption to the spp
%   .timeperiteration = the time in sec that each iteration has to find a valid sooption
%   .maxiterations = the maximum amount of iterations
%%
fmin = 0;
sensors_selected = input.solution.sensors_selected;

while fmin <= input.discretization.wpn
clear Optimization.Continuous.fitfct.cmqm
sensors_selected = sensors_selected(2:end);
opt = Optimization.Continuous.prepare_opt(input, input.solution);
opt.wpn = input.discretization.wpn;


fmin = Optimization.Continuous.fitfct.cmqm(x);




opt = cmaes('defaults');
opt_vect = [opt.x, opt.phi];
ub = ones(size(opt_vect));
lb = zeros(size(opt_vect));
opt.LBounds = lb;
opt.UBounds = ub;
maxtime = config.maxtime;

opt_fct = @Optimization.Continuous.fitfct.cmqm;
fun_check_stopflag = @(flags) any(strcmpi(flags, 'stoptoresume')|strcmpi(flags, 'manual'));
solutions = {};


    timer_id = tic;
[poses, fmin, counteval, stopflag, out, bestever ]  = cmaes( opt_fct, opt_vect, [], opt );
opt.Resume = true;
while toc(timer_id) < maxtime && fun_check_stopflag(stopflag) && fmin > input.discretization.wpn
    [poses, fmin, counteval, stopflag, out, bestever ]  = cmaes( opt_fct, poses, [], opt );
end
sol.poses = poses;
sol.fmin = fmin;
sol.conteval = counteval;
sol.stopflag = stopflag;
sol.out = out; 
sol.bestever = bestever;
sol.sensors_selected = sensors_selected;
solutions{end+1} = sol;
end

return 

%%
% load tmp\conference_room\gco.mat
% clearvars -except gco;
clear functions;
%%
sol = gco{10, 10};
input = Experiments.Diss.conference_room(sol.num_sp, sol.num_wpn);
input.solution = sol;
opt = Optimization.Continuous.prepare_opt(input, sol);
opt.wpn = input.discretization.wpn;
%%%%
% opt.x = opt.x+0.01;
% opt.phi = opt.phi+0.2;
% Optimization.Continuous.fitfct.cmqm(opt)
%%
x = opt.x+0.01;
phi = opt.phi+0.5;
Optimization.Continuous.fitfct.cmqm(x, phi)

