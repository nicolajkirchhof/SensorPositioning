function [ solutions ] = cmqm_cmaes_it( input, config )
%START Solves the sensorplacement by approximation of the
% total number of sensors and an iterative nonlinear search
% input
%   .solution = the found approximate sooption to the spp
% config
%   .timeperiteration = the time in sec that each iteration has to find a valid sooption
%   .stopiter = maximum function evaluations before next time check
%%
fmin = 0;
sp = [[0;0;0], input.discretization.sp(:, input.solution.sensors_selected)];
solutions = {};
cnt = 0;
config.fmin = 0;
%%
while fmin <= 0 % && cnt <= config.maxiterations
    
    timer = tic;
    max_tries = size(sp, 2);
    num_try = 0;
    selected = true(1, max_tries);
    selected(1) = false;
    
    fmin = 0;
    while toc(timer) < config.timeperiteration && fmin >= 0 && num_try < max_tries
        cmcq_opt = Optimization.Continuous.prepare_opt(input, sp(:, circshift(selected, num_try,2))  );
        cmcq_opt.wpn = input.discretization.wpn;
        config.filename = sprintf('cmaes_tmp%03d.mat', cnt);
        config.resume = false;
        sol = Optimization.Continuous.cmqm_cmaes(cmcq_opt, config);
        fmin = sol.fmin;
        num_try = num_try + 1;
    end
    
    sp = sol.sp;
    sol.filename = config.filename;
    cnt = cnt + 1;
    %%
    solutions{end+1} = sol;
end
% if numel(solutions) < 2
%     solutions{end+1} = sol;
%     solutions{1}.sp = 
% end

%% ADD FINAL RUN WITH LAST VALID
sol = solutions{end-1};
cmcq_opt = Optimization.Continuous.prepare_opt(input, sol.sp);
cmcq_opt.wpn = input.discretization.wpn;
config.timeperiteration = config.timeperiteration;
config.stopiter = 2*config.stopiter;
config.filename = sol.filename;
config.resume = true;
config.fmin = -inf;
sol = Optimization.Continuous.cmqm_cmaes(cmcq_opt, config);

sol.discretization = input.discretization;
sol.discretization.num_sensors = size(sol.sp, 2);
sol.sensors_selected = 1:numel(sol.discretization.num_sensors);

%% ONLY CONVERT LAST VALID!!!
[sol.discretization.sp, sol.discretization.vfovs, sol.discretization.vm] = ...
    Discretization.Sensorspace.vfov(sol.sp, input.environment, sol.discretization.wpn, input.config.discretization, true);
[sol.discretization.spo, sol.discretization.spo_ids] = Discretization.Sensorspace.sameplace(sol.discretization.sp, input.config.discretization.sensor.fov);
[sol.discretization.sc, sol.discretization.sc_wpn] = Discretization.Sensorspace.sensorcomb(sol.discretization.vm, sol.discretization.spo, input.config.discretization);
sol.quality = Quality.generate(sol.discretization, Configurations.Quality.diss);

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
sol = gco{51, 51};
input = Experiments.Diss.conference_room(sol.num_sp, sol.num_wpn);
input.solution = sol;
config.timeperiteration = 1800;
config.stopiter = 500;
solutions = Optimization.Continuous.cmqm_cmaes_it(input, config);
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
