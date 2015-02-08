function [ sol ] = cmqm_cmaes( input )
%START Solves the sensorplacement by approximation of the 
% total number of sensors and an iterative nonlinear search
%%
% load tmp\conference_room\gco.mat
clearvars -except gco;
clear functions;
sol = gco{10, 10};
input = Experiments.Diss.conference_room(sol.num_sp, sol.num_wpn);
lut = Optimization.Continuous.prepare_lut(input, sol);

Optimization.Continuous.fitfct.cmqcm(lut)
%%
x = lut.x+0.01;
phi = lut.phi+0.5;
Optimization.Continuous.fitfct.cmqcm(x, phi)





%% remove edges that are on boundaries
gpoly = mb.boost2visilibity(input.environment.combined);
edges = cellfun(@(x) [x, circshift(x, -1, 1)], gpoly, 'uniformoutput', false);

intersectEdgePolygon
%%
p_center = env_edges_all(:,[1 2])+((-env_edges_all(:,[1 2])+env_edges_all(:,[3 4]))./2);
in = binpolygon(int64(p_center'), pc.environment.obstacles.poly);
env_edges = env_edges_all(~in, :);    


%%
env_edge_lengths = edgeLength(env_edges);
env_edge_sumlength = sum(env_edge_lengths);
env_edge_normlength = env_edge_lengths/env_edge_sumlength;
env_edge_lookup = cumsum([0; env_edge_lengths(1:end-1)]/env_edge_sumlength);

%%%
% find sensor edges and just take one of the edges if sensor is on endpoint
if size(sel_sensors, 2) == size(env_edges,1)
    sels_first = isPointOnEdge(sel_sensors(1:2,1)', env_edges);
    sel_sensors_edge_mapping = [sels_first'; isPointOnEdge(sel_sensors(1:2,2:end)', env_edges)];
else
    sel_sensors_edge_mapping = isPointOnEdge(sel_sensors(1:2,:)', env_edges);
end
[rows columns] = find(sel_sensors_edge_mapping);
[urows, urowsid] = unique(rows);
sel_sensors_edge_ids = columns(urowsid);
sel_sensors_edge_pos = edgePosition(sel_sensors(1:2,:)', env_edges(sel_sensors_edge_ids, :)).*env_edge_normlength(sel_sensors_edge_ids);
sel_sensors_abs_pos = sel_sensors_edge_pos+env_edge_lookup(sel_sensors_edge_ids);
%%


ub = ones(size(opt_vect));
lb = zeros(size(opt_vect));
opt.LBounds = lb;
opt.UBounds = ub;
maxtime = 7200;

% write_log('#off');
% opt.StopIter = 500;
% tic;
fun_check_stopflag = @(flags) any(strcmpi(flags, 'stoptoresume')|strcmpi(flags, 'manual'));
[poses, fmin, counteval, stopflag, out, bestever ]  = cmaes( @opt_fct, opt_vect, [], opt );
opt.Resume = true;
while toc < maxtime && fun_check_stopflag(stopflag)
    [poses, fmin, counteval, stopflag, out, bestever ]  = cmaes( @opt_fct, poses, [], opt );
end
pc.common.verbose = true;
sol.poses = poses;
sol.fmin = fmin;
sol.conteval = counteval;
sol.stopflag = stopflag;
sol.out = out; 
sol.bestever = bestever;

%%
clear variables;
input = Experiments.Diss.conference_room(50, 50);
sol = load('tmp/conference_room/gco/gco__50_50.mat');
input.solution = sol.input.solution;

env_edges_all = {};
for idp = 1:numel(penv)
    env_edges_all{idp} = double([penv{idp}(:,1:end-1)', penv{idp}(:,2:end)']);
end
env_edges_all = cell2mat(env_edges_all');
%%
% sel_sensors(1:2,:) = bsxfun(@rdivide, bsxfun(@minus, sel_sensors(1:2,:), pmin), pdiff);
sel_sensors_phi = sel_sensors(3,:)/(2*pi);

opt_vect = [sel_sensors_abs_pos'; sel_sensors_phi];
opt_vect = opt_vect(:);

pc.problem.num_sensors = numel(pc.model.it_fmin.sol.sensors);
max_comb = nchoosek(pc.problem.num_sensors, 2);

fun_getEdge = @(x) arrayfun(@(el) sum(env_edge_lookup<=el), x);
fun_getPosition = @(eid, x) cell2mat(arrayfun(@(id, el) pointOnLine(createLine(env_edges(id,1:2), env_edges(id,3:4)), el-env_edge_lookup(id)), eid, x, 'uniformoutput', false));
% max_edge_dist = 500;
% poses = opt_vect;
%% 
function x = opt_fct(x_in)
        x_in = reshape(x_in, 2, []);
%         poses(1:2,:) = bsxfun(@times, bsxfun(@plus, poses(1:2,:), pmin), pdiff);
        pos = fun_getPosition(fun_getEdge(x_in(1,:)'), x_in(1,:)');
        ang= x_in(2,:)*(2*pi);
        
        
        pc.problem.S = [pos'; ang];
        pc.progress.sensorspace.visibility = false;
        pc.progress.sensorspace.sensorcomb = false;
        pc = sensorspace.visibility(pc);
        two_coverage_penalty = 2-sum(pc.problem.xt_ij,1);
        two_coverage_penalty(two_coverage_penalty<0) = 0;
        two_coverage_penalty = 1e5*two_coverage_penalty;
%         pc = quality.wss.dop_ang(pc, 1e6, 1e3);
        qname = pc.model.it_fmin.quality.name;
        pc = pc.quality.(qname).fct(pc, pc.model.it_fmin.quality.param);
%         x_qual = sum(cellfun(@(x) 1e2-min(x), pc.quality.wss_dop_ang.val(~cellfun(@isempty,pc.quality.wss_dop_ang.val))));

        flt_qval = cellfun(@isempty,pc.quality.(qname).val);
        pc.quality.(qname).val(flt_qval) = {0};
        pc.problem.wp_qual = cellfun(@(x) -max(x), pc.quality.(qname).val);
        pc.problem.wp_qual = pc.problem.wp_qual(:) + two_coverage_penalty(:);
        x_qual = sum(pc.problem.wp_qual);
%         comb_penalty = 1e4*(max_comb-pc.problem.num_comb);    
%         dist_env = zeros(size(poses,2), 1);
%         for idp = 1:size(poses, 2)
%             dist_env(idp) = min(distancePointEdge(poses(:,idp)', env_edges));
%         end
%         dist_penalty =  prod(exp(dist_env./pmxdist));
%         fprintf(1, 'x=%g , dist_pen=%g\n', x, dist_penalty);
        x = x_qual+sum(two_coverage_penalty);
            
%         pc = quality.wss.dd_dop(pc, 1);
% x = sum(cellfun(@(x) numel(x)/sum(x), pc.quality.wss_dd_dop.val));
%%


%%
opt = cmaes;
% opt.Display = 'iter';
% opt.PlotFcns = { @optimplotx; % plots the current point.
% @optimplotfunccount; % plots the function count.
% @optimplotfval; % plots the function value.
% @optimplotresnorm; % plots the norm of the residuals.
% @optimplotstepsize; % plots the step size.
% @optimplotfirstorderopt}; % plots the first-order optimality measure.
% opt_h = 
% prob.options = opt;
% prob.objective = @(x) opt_fct(x);
% prob.solver = 'lsqnonlin';
% prob.x0 = opt_vect;
ub = ones(size(opt_vect));
lb = zeros(size(opt_vect));
opt.LBounds = lb;
opt.UBounds = ub;

% ub(1:3:end) = pmax(1);
% ub(2:3:end) = pmax(2);
% ub(3:3:end) = 2*pi;
% lb(1:3:end) = pmin(1);
% lb(2:3:end) = pmin(2);
% % ub(3:3:end) = 2*pi;
% prob.ub = ub;
% prob.lb = lb;
if nargin < 2 || isempty(maxtime)
    maxtime = 7200;
end

write_log('#off');
pc.common.verbose = false;
opt.StopIter = 500;
tic;
fun_check_stopflag = @(flags) any(strcmpi(flags, 'stoptoresume')|strcmpi(flags, 'manual'));
[poses, fmin, counteval, stopflag, out, bestever ]  = cmaes( @opt_fct, opt_vect, [], opt );
opt.Resume = true;
while toc < maxtime && fun_check_stopflag(stopflag)
    [poses, fmin, counteval, stopflag, out, bestever ]  = cmaes( @opt_fct, poses, [], opt );
end
pc.common.verbose = true;
sol.poses = poses;
sol.fmin = fmin;
sol.conteval = counteval;
sol.stopflag = stopflag;
sol.out = out; 
sol.bestever = bestever;

poses = reshape(poses, 2, []);
pos_xy = fun_getPosition(fun_getEdge(poses(1,:)'), poses(1,:)');
pos_phi= poses(2,:)*(2*pi);
sol.poses = [pos_xy'; pos_phi];

opt_fct(bestever.x);
sol.pc = pc;
% pcout.problem.V(pcout.model.sol.sensors.ids) = pc.problem.V;
% xbest = reshape(bestever.x, 2, []);
% xbest_xy = fun_getPosition(fun_getEdge(xbest(1,:)'), xbest(1,:)');
% xbest_phi= xbest(2,:)*(2*pi);
% sol.pc.problem.S =  [xbest_xy'; xbest_phi];
% sol.pc.problem.num_sensors = size(sol.pc.problem.S, 2);
sol.x = true(1, sol.pc.problem.num_sensors);
sol.ax = sol.pc.problem.wp_qual;
sol.variables.names = arrayfun(@(id) sprintf('s%d',id), 1:sol.pc.problem.num_sensors, 'uniformoutput', false);

write_log('#on');


%% testing
close all; fclose all; clear all;
%
% clear all;
upda = [1.5 2.5 8];
uada = [8 4 1];
for i = 3:-1:1
fclose all; clear pc;
pc = processing_configuration('sides4_nr0');
pc.environment.file = 'res/floorplans/IrfSeminarraumFinca.dxf';
upd = 100*upda(i);
pc.sensorspace.uniform_position_distance = upd;
uad = deg2rad(45/uada(i));
pc.sensorspace.uniform_angle_distance = uad;
pc.workspace.grid_position_distance = upd;
pc.workspace.wall_distance = 200;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc.model.wss_qclip.quality.param = 5;
pc.model.wss_qclip.quality.min = 0.5;
pc.model.wss_qclip.quality.name = pc.quality.types.wss_dd_dop;
pc.model.it_fmin.quality.fct = @model.wss.qclip;
pc.model.it_fmin.quality.name = pc.quality.types.wss_dd_dop;
pc.model.it_fmin.quality.param = 5;
% dbstop in src\+model\+it\fmin.m
pc = model.it.fmin(pc);
draw.ws_solution(pc, pc.model.it_fmin.sol);
%%
% profile on;
sall = pc.model.it_fmin.sol.sensors;
sol = {};
%%
fn = sprintf('irf_seminar_cmaes-supd%d-wgpd%d-suad%d', upd, upd, rad2deg(uad));
for ids = 1:round(numel(sall)/2)
% for ids = [1,10,17]
    pc.model.it_fmin.sol.sensors = sall(ids:end);
    sol{ids} = solver.it.cmaes(pc);
    write_log('ids %d done');
    save([fn 'it' num2str(ids)]);
end

% profile viewer;
end
%%
if ~isempty(cpx.Solution)
    pc.model.sol = cpx.Solution;
    pc.model.it_fmin.sol.sensors = unique(pc.problem.sc_idx(cpx.Solution.x>0, :));
    pc.model.sol.sensors.min = sum(cpx.Solution.x)/2;
    pc.model.sol.sensors.max = sum(cpx.Solution.x);
    %%
    figure, draw.wss_solution(pc, cpx.Solution);
    pcin = pc;
    %%    
    [pcopt, pcused] = solver.it.nonlin.cmaes(pcin);
    %%
    sol.x = cpx.Solution.x;
    sol.ax = sum(pcused.problem.xt_ij, 1)';
    pcopt.problem.V(pcopt.model.sol.sensors.ids) = pcused.problem.V;
    figure, draw.wss_solution(pcopt, sol);
%     draw.ws_solution(pc, cpx.Solution);
%     draw.wss_wp_solution(pc, cpx.Solution);
%     draw.ws_wp_solstats(pc, cpx.Solution);
    
end


