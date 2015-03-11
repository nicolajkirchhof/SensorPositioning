function [ solutions ] = cmcqm_nonlin_it( input, config )
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
fmin_best = 1;
sol_best = {};
%%
while fmin <= 0 % && cnt <= config.maxiterations
       
    cmcq_opt = Optimization.Continuous.prepare_opt(input, sp);
%     cmcq_opt.wpn = input.discretization.wpn;
%     config.filename = sprintf('cmaes_tmp%03d.mat', cnt);
    
    fmin = 1;
    cnt_try = 0;
    timer = tic;
    while fmin > 0 && cnt_try <= config.restarts && toc(timer) < config.probingtime
        sol = Optimization.Continuous.cmcqm_nonlin(cmcq_opt, config);
        fmin = sol.fmin;
        cmcq_opt.x = rand(size(cmcq_opt.x));
        cmcq_opt.phi = rand(size(cmcq_opt.phi));
        fprintf(1, '\n Did not find solution in try %d restarting. \n', cnt_try);
        cnt_try = cnt_try + 1;
        if fmin < fmin_best
            sol_best = sol;
            fmin_best = fmin;
        end
    end
    
    sol_best.solutiontime = toc(timer);
    sp = sol_best.sp(:, 2:end);
%     sol.filename = config.filename;
    cnt = cnt + 1;
    %%
    solutions{end+1} = sol_best;
end


%% ADD FINAL RUN WITH LAST VALID
timer = tic;
if numel(solutions) > 1
    sol = solutions{end-1};
else
    sol = solutions{1};
end
timeelapsed = sol.solutiontime;
cmcq_opt = Optimization.Continuous.prepare_opt(input, sol.sp);
cmcq_opt.wpn = input.discretization.wpn;
config.timeperiteration = config.timeperiteration;
config.fmin = -inf;
config.probingtime = config.timeperiteration;
if numel(solutions) > 1
    sol = Optimization.Continuous.cmcqm_nonlin(cmcq_opt, config);
end

sol.discretization = input.discretization;
sol.discretization.num_sensors = size(sol.sp, 2);

sol.sensors_selected = 1:numel(sol.discretization.num_sensors);


%% ONLY CONVERT LAST VALID!!!
[sol.discretization.sp, sol.discretization.vfovs, sol.discretization.vm] = ...
    Discretization.Sensorspace.vfov(sol.sp, input.environment, sol.discretization.wpn, input.config.discretization, true);
[sol.discretization.spo, sol.discretization.spo_ids] = Discretization.Sensorspace.sameplace(sol.discretization.sp, input.config.discretization.sensor.fov);
[sol.discretization.sc, sol.discretization.sc_wpn] = Discretization.Sensorspace.sensorcomb(sol.discretization.vm, sol.discretization.spo, input.config.discretization);
if ~isempty(sol.discretization.sc_wpn)
    sol.quality = Quality.generate(sol.discretization, Configurations.Quality.diss);
end
sol.solutiontime = timeelapsed + toc(timer);
if numel(solutions) > 1
    solutions{end-1} = sol;
else
    solutions{1} = sol;
end
%%
% Discretization.draw(sol.discretization, input.environment);
% Discretization.draw_wpn_max_qualities(sol.discretization, sol.quality);
% axis auto;
return

%%
load tmp\conference_room\gco.mat
%%
profile on;
sol = gco{51, 11};
input = Experiments.Diss.conference_room(sol.num_sp, sol.num_wpn);
input.solution = sol;
config.timeperiteration = 1800;
config.restarts = 50;
config.UseParallel = false;
config.verbose = false;
config.probingtime = 60*(11*5);
solutions = Optimization.Continuous.cmcqm_nonlin_it(input, config);
profile viewer
