function [ solutions ] = cmqm_nonlin_it( input, config )
%START Solves the sensorplacement by approximation of the
% total number of sensors and an iterative nonlinear search
% input
%   .solution = the found approximate sooption to the spp
% config
%   .timeperiteration = the time in sec that each iteration has to find a valid sooption
%   .stopiter = maximum function evaluations before next time check
%%
fmin = 0;
sp = input.discretization.sp(:, input.solution.sensors_selected);
solutions = {};
cnt = 0;
config.fmin = 0;
%%
while fmin <= 0 % && cnt <= config.maxiterations
       
    cmcq_opt = Optimization.Continuous.prepare_opt(input, sp);
    cmcq_opt.wpn = input.discretization.wpn;
    config.filename = sprintf('cmaes_tmp%03d.mat', cnt);
    
    fmin = 1;
    cnt_try = 0;
    timer = tic;
    while fmin > 0 && cnt_try <= config.restarts
        sol = Optimization.Continuous.cmqm_nonlin(cmcq_opt, config);
        fmin = sol.fmin;
        cmcq_opt.x = rand(size(cmcq_opt.x));
        cmcq_opt.phi = rand(size(cmcq_opt.phi));
        fprintf(1, '\n Did not find solution in try %d restarting. \n', cnt_try);
        cnt_try = cnt_try + 1;
    end
    
    sol.solutiontime = toc(timer);
    sp = sol.sp(:, 2:end);
    sol.filename = config.filename;
    cnt = cnt + 1;
    %%
    solutions{end+1} = sol;
end


%% ADD FINAL RUN WITH LAST VALID
timer = tic;
sol = solutions{end-1};
timeelapsed = sol.solutiontime;
cmcq_opt = Optimization.Continuous.prepare_opt(input, sol.sp);
cmcq_opt.wpn = input.discretization.wpn;
config.timeperiteration = config.timeperiteration;
config.fmin = -inf;
sol = Optimization.Continuous.cmqm_nonlin(cmcq_opt, config);

sol.discretization = input.discretization;
sol.discretization.num_sensors = size(sol.sp, 2);
sol.sensors_selected = 1:numel(sol.discretization.num_sensors);

%% ONLY CONVERT LAST VALID!!!
[sol.discretization.sp, sol.discretization.vfovs, sol.discretization.vm] = ...
    Discretization.Sensorspace.vfov(sol.sp, input.environment, sol.discretization.wpn, input.config.discretization, true);
[sol.discretization.spo, sol.discretization.spo_ids] = Discretization.Sensorspace.sameplace(sol.discretization.sp, input.config.discretization.sensor.fov);
[sol.discretization.sc, sol.discretization.sc_wpn] = Discretization.Sensorspace.sensorcomb(sol.discretization.vm, sol.discretization.spo, input.config.discretization);
sol.quality = Quality.generate(sol.discretization, Configurations.Quality.diss);
sol.solutiontime = timeelapsed + toc(timer);

solutions{end-1} = sol;
%%
% Discretization.draw(sol.discretization, input.environment);
% Discretization.draw_wpn_max_qualities(sol.discretization, sol.quality);
% axis auto;
return

%%
load tmp\conference_room\gco.mat
%%
profile on;
sol = gco{1, 1};
input = Experiments.Diss.conference_room(sol.num_sp, sol.num_wpn);
input.solution = sol;
config.timeperiteration = 1800;
config.restarts = 5;
config.UseParallel = false;
solutions = Optimization.Continuous.cmqm_nonlin_it(input, config);
profile viewer
%%
profile on;
sol = gco{1, 1};
input = Experiments.Diss.large_flat(sol.num_sp, sol.num_wpn);
input.solution = sol;
config.timeperiteration = 1800;
config.stopiter = 500;
%%
solutions = Optimization.Continuous.cmqm_cmaes_it(input, config);
profile viewer
