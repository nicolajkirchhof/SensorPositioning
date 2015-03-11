function [ solutions ] = cmcqm_cmaes_it( input, config )
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
    
%     timer = tic;
        cmcq_opt = Optimization.Continuous.prepare_opt(input, sp);
        config.filename = sprintf('cmaes_tmp%03d.mat', cnt);
        config.resume = false;
        config.restarts = config.restarts; 
        sol = Optimization.Continuous.cmcqm_cmaes(cmcq_opt, config);
        fmin = sol.fmin;
    
    sp = sol.sp(:, 2:end);
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
if numel(solutions) > 1
    id_best = numel(solutions)-1;
else
    id_best = 1;
end
sol = solutions{id_best};
cmcq_opt = Optimization.Continuous.prepare_opt(input, sol.sp);
cmcq_opt.wpn = input.discretization.wpn;
config.timeperiteration = config.timeperiteration;
config.stopiter = 2*config.stopiter;
config.filename = sol.filename;
config.resume = true;
config.restarts = 1;
config.fmin = 0;
if numel(solutions) > 1
    sol = Optimization.Continuous.cmcqm_cmaes(cmcq_opt, config);
end

sol.discretization = input.discretization;
sol.discretization.num_sensors = size(sol.sp, 2);
sol.sensors_selected = 1:numel(sol.discretization.num_sensors);

%% ONLY CONVERT LAST VALID!!!
[sol.discretization.sp, sol.discretization.vfovs, sol.discretization.vm] = ...
    Discretization.Sensorspace.vfov(sol.sp, input.environment, sol.discretization.wpn, input.config.discretization, true);
[sol.discretization.spo, sol.discretization.spo_ids] = Discretization.Sensorspace.sameplace(sol.discretization.sp, input.config.discretization.sensor.fov);
[sol.discretization.sc, sol.discretization.sc_wpn] = Discretization.Sensorspace.sensorcomb(sol.discretization.vm, sol.discretization.spo, input.config.discretization);
sol.quality = Quality.generate(sol.discretization, Configurations.Quality.diss);

solutions{id_best} = sol;
%%
% Discretization.draw(sol.discretization, input.environment);
% Discretization.draw_wpn_max_qualities(sol.discretization, sol.quality);
% axis auto;
return
%%
% name = 'conference_room';
name = 'large_flat';
load(sprintf('tmp/%s/gco.mat', name));
%%
clearvars -except gco name;
clear cmcqm;
%%%
profile on;
sol = gco{10, 10};
input = Experiments.Diss.(name)(sol.num_sp, sol.num_wpn);
input.solution = sol;
config.timeperiteration = 1800;
config.stopiter = 500;
config.restarts = 10;
config.fileprefix = 'lf';
solutions = Optimization.Continuous.cmcqm_cmaes_it(input, config);
profile viewer
%%
load tmp\conference_room\gco.mat
%%
clearvars -except gco name;
% clear cmcqm;
%%%
profile on;
sol = gco{10, 10};
input = Experiments.Diss.(name)(sol.num_sp, sol.num_wpn);
input.solution = sol;
config.timeperiteration = 1800;
config.stopiter = 500;
config.restarts = inf;
config.fileprefix = 'cr';
config.fmin = 0;
solutions = Optimization.Continuous.cmcqm_cmaes_it(input, config);
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
