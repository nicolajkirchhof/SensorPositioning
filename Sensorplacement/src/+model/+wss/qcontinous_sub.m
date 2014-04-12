function pc = qcontinous_sub(pc)
%% DIRECTIONAL adds the q_sin quality values as separate constraints
%%% For every workspace point a quality variable is created for every sensorcombination from
% which the point is seen. The quality is than applied to the constraint matrix and
% the constraint is only fullfilled if the min quality is fullfilled


[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
model_type = [model_prefix '_' model_name];
% model_type = 'wss_qcontinous';
if pc.progress.model.(model_type)
    pc = model.enable(pc, model_type);
    return;
end

qname = pc.model.(model_type).quality.name;
if ~pc.progress.quality.(qname)
    pc = pc.quality.(qname).fct(pc, pc.model.(model_type).quality.param );
end

[pc] = model.init(pc, model_type);

%%
write_log(' adding %s model', model_type);
fid = pc.model.(model_type).obj.fid;
%%
write_log(' obj...');
qvalsummax = sum(pc.quality.(pc.model.(model_type).quality.name).valsum);
model.write.tag_2value_lines(fid, ' -%0.4e w%d', ones(pc.problem.num_positions, 1)*(1/qvalsummax), (1:pc.problem.num_positions)', pc.common.linesize);
write_log('... done ');
%% write constraints
% A - Example: Here s2s3 and s3s4 would be choosen, since they decrease the qualities the most.
% Additionally s1s2 would be choosen as well, since it would increase the objective function with
% the 1 value of s1 and s1s2 (=2) but decrease it by -.5+-.9+-.7=-2.1.
%      s1s2  s2s3   s3s4  w1   w2   w3
% 0 <=  5     10    100                <= inf
% 0 <= .9         .6          .8       <= inf
% 0 <= .7         .9          .8       <= inf
%
% COMPUTE as
%             A_q = [q_sij_i q_sij_j]        A_w
% qw1_obj = -1
%     idsc = zeros(pc.problem.num_comb, 1);
%     fid = pc.model.file.st.fid;
%% write st values
fid = pc.model.(model_type).st.fid;
%%
loop_display(pc.problem.num_positions, 10);
write_log(' writing constraints...');
% qvalsbwmax = max(pc.quality.(pc.model.(model_type).quality.name).valbw);
qvalsbwmax = 0;
qvalsummax = sum(pc.quality.(pc.model.(model_type).quality.name).valsum);
for idw = 1:pc.problem.num_positions
    %     for idw = 1:10
    %%
    wp_comb_ind = find(pc.problem.wp_sc_idx(:, idw));
    qvals = pc.quality.(pc.model.(model_type).quality.name).val{idw};    
    wp_comb_flt = (qvals > pc.model.(model_type).quality.reject);
    qscaled = qvals(wp_comb_flt);%./(qvalsbwmax+qvalsummax);
%     qscaled = qvals(wp_comb_flt)./qvalsbw(wp_comb_flt);
%     q_row_scale = sum(qscaled)/1;
% q_row_scale = 1;
%     qscaled = qscaled/q_row_scale;
%     qscaled = qscaled * 10;
    if isempty(wp_comb_flt)
        error('model not solveable');
    end
    wp_comb_ind = wp_comb_ind(wp_comb_flt);
    %%
    c_cnt = fprintf(fid, ' w%d_comb:', idw);
    model.write.tag_2value_lines(fid, ' +%0.4e s%ds%d',qscaled , pc.problem.sc_idx(wp_comb_ind,:), pc.common.linesize, c_cnt, false);
    %     model.write.tag_value_lines(fid, ' +inf s%ds%d', pc.problem.sc_idx(setdiff((1:pc.problem.num_comb)', wp_comb_ind),:), pc.common.linesize, c_cnt, false);
    fprintf(fid, ' -w%d', idw);
    fprintf(fid, ' = 0\n');
    if mod(idw,pc.problem.num_positions/100)<1
        loop_display(idw);
    end
end
%%
fid = pc.model.(model_type).bounds.fid;
%%
write_log(' bounds...');
%qmins = repmat(pc.model.(model_type).quality.min/(qvalsbwmax+qvalsummax), size((1:pc.problem.num_positions)')) ;
qmins = repmat(pc.model.(model_type).quality.min, size((1:pc.problem.num_positions)')) ;
model.write.tag_2value_lines(fid, '%e <= w%d\n', qmins, (1:pc.problem.num_positions)', pc.common.linesize);
write_log('... done ');
%%
write_log('...done ');
pc = model.finish(pc, model_type);
write_log('... done ');
return;
%% testing
close all; clearvars all; fclose all; clear write_log
clear all;
pc = processing_configuration('sides4_nr0');
pc.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
pc.sensorspace.uniform_position_distance = 100*4;
pc.sensorspace.uniform_angle_distance = deg2rad(45/2);
pc.workspace.grid_position_distance = 100*4;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc.model.wss_qcontinous.quality.name = pc.quality.types.wss_dd_dop;
pc.model.wss_qcontinous.quality.param = 500;
pc = model.ws.coverage(pc);
pc = model.ws.sameplace(pc);
% pc.model.wss_sc_backward.obj.enable = false;
% pc = model.wss.sc_backward(pc);
pc.model.wss_sc_forward.obj.enable = false;
pc = model.wss.sc_forward(pc);
pc = model.wss.qcontinous(pc);
pc = model.save(pc);
%%%
cpx = solver.cplex.start(pc.model.lastsave);
if ~isempty(cpx.Solution)
    %     draw.solution(pc, cpx.Solution);
    draw.wss_wp_solution(pc, cpx.Solution);
    draw.ws_wp_solstats(pc, cpx.Solution);
end
%%
figure, hold on;
sz = {3, 2};
subplot(sz{:},[1 2])
s_idx = 1:pc.problem.num_sensors;
plot(s_idx, cpx.Solution.x(s_idx), '.r');
subplot(sz{:}, [3 4])
c_idx = pc.problem.num_sensors+(1:pc.problem.num_comb);
plot(c_idx, cpx.Solution.x(c_idx), '.g');
subplot(sz{:},5)
w_idx = pc.problem.num_sensors+pc.problem.num_comb+(1:pc.problem.num_positions);
plot(w_idx, cpx.Solution.x(w_idx), '.b', 'MarkerSize', 20);
subplot(sz{:},6)
hold on;
boxplot(cpx.Solution.x(w_idx));

% plot(cpx.Solution.x(end-pc.problem.num_sensors-pc.problem.num_comb:end-pc.problem.num_sensors), '.g');
% pc = quality.wss.dd_dop(pc, 4);
% figure, draw.wss_qstats(pc.quality.wss_dd_dop.val);
% % pc.model.wss_qclip.quality.name = pc.quality.types.wss_dirdist;
% % pc.model.wss_qclip.quality.name = pc.quality.types.wss_distgeom;
% pc.model.wss_qclip.quality.name = pc.quality.types.wss_directional;
% pc.model.wss_qclip.obj.enable = false;
% pc.model.wss_qclip.bin.enable = false;
% pc = model.ws.coverage(pc);
% pc = model.wss.sc_backward(pc);
% % pc = model.wss.sensorcomb(pc);
% pc = model.wss.qclip(pc);
% %%%
% pc = model.save(pc);
% start_cplex(pc.model.lastsave);
% %%%
% figure,
% solution = read_solution(pc.model.lastsave);
% draw.wss_solution(pc, solution);
% draw.solution(pc, solution);