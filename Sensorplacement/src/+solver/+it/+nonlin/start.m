function [ pcout ] = start( pc )
%START Solves the sensorplacement by approximation of the 
% total number of sensors and an iterative nonlinear search
%%
pcout = pc;
%%
pc.sensorspace.min_visible_area  = 0;
pc.sensorspace.min_visible_positions = 0;

pmax = double(max(pc.environment.combined.poly, [], 2));
pmin = double(min(pc.environment.combined.poly, [], 2));
pdiff = pmax-pmin;

opt_vect = pc.problem.S(:, pc.model.sol.sensors.ids);
opt_vect(1:2,:) = bsxfun(@rdivide, bsxfun(@minus, opt_vect(1:2,:), pmin), pdiff);
opt_vect(3,:) = opt_vect(3,:)/(2*pi);
opt_vect = opt_vect(:);

% poses = opt_vect;
%% 
function x = opt_fct(poses)
        poses = reshape(poses, 3, []);
        poses(1:2,:) = bsxfun(@times, bsxfun(@plus, poses(1:2,:), pmin), pdiff);
        poses(3,:) = poses(3,:)*(2*pi);
        
        pc.problem.S = poses;
        pc.progress.sensorspace.visibility = false;
        pc.progress.sensorspace.sensorcomb = false;
        pc = sensorspace.visibility(pc);
        pc = quality.wss.dop_ang(pc);
        x = cellfun(@sum, pc.quality.wss_dop_ang.val);
%%
end

%%
opt = optimset('lsqnonlin');
opt.Display = 'iter';
opt.PlotFcns = { @optimplotx; % plots the current point.
@optimplotfunccount; % plots the function count.
@optimplotfval; % plots the function value.
@optimplotresnorm; % plots the norm of the residuals.
@optimplotstepsize; % plots the step size.
@optimplotfirstorderopt}; % plots the first-order optimality measure.
% opt_h = 
prob.options = opt;
prob.objective = @(x) opt_fct(x);
prob.solver = 'lsqnonlin';
prob.x0 = opt_vect;
ub = ones(size(opt_vect));
lb = zeros(size(opt_vect));

% ub(1:3:end) = pmax(1);
% ub(2:3:end) = pmax(2);
% ub(3:3:end) = 2*pi;
% lb(1:3:end) = pmin(1);
% lb(2:3:end) = pmin(2);
% % ub(3:3:end) = 2*pi;
prob.ub = ub;
prob.lb = lb;

write_log('#off');
poses = lsqnonlin(prob);
poses = reshape(poses, 3, []);
poses(1:2,:) = bsxfun(@times, bsxfun(@plus, poses(1:2,:), pmin), pdiff);
poses(3,:) = poses(3,:)*(2*pi);
pcout.problem.S(:, pcout.model.sol.sensors.ids) = poses;
write_log('#on');

%%



%%%

return;
%% testing
%% testing
close all; fclose all; clear all;
%
% clear all;
pc = processing_configuration('sides4_nr0');
pc.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
pc.sensorspace.uniform_position_distance = 100*5;
pc.sensorspace.uniform_angle_distance = deg2rad(45/2);
pc.workspace.grid_position_distance = 100*2;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc.model.wss_qclip.quality.min = 0.5;
pc.model.wss_qclip.quality.name = pc.quality.types.wss_dd_dop;
pc = model.wss.qclip(pc);
%%
pc = model.save(pc);
%
cpx = solver.cplex.start(pc.model.lastsave);
if ~isempty(cpx.Solution)
    pc.model.sol = cpx.Solution;
    pc.model.sol.sensors.ids = unique(pc.problem.sc_idx(cpx.Solution.x>0, :));
    pc.model.sol.sensors.min = sum(cpx.Solution.x)/2;
    pc.model.sol.sensors.max = sum(cpx.Solution.x);
    %%
    figure, draw.wss_solution(pc, cpx.Solution);
    pcopt = solver.it.nonlin.start(pc);
    figure, draw.wss_solution(pcopt, cpx.Solution);
%     draw.ws_solution(pc, cpx.Solution);
%     draw.wss_wp_solution(pc, cpx.Solution);
%     draw.ws_wp_solstats(pc, cpx.Solution);
    
end
end