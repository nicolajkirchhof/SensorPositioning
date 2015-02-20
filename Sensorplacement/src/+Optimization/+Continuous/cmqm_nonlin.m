function [ pcout ] = cmqm_nonlin( pc )
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

