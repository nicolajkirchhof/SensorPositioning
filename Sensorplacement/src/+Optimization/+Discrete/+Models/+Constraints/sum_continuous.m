function qcontinous_sub(discretization, quality, config)
%% DIRECTIONAL adds the q_sin quality values as separate constraints
%%% For every workspace point a quality variable is created for every sensorcombination from
% which the point is seen. The quality is than applied to the constraint matrix and
% the constraint is only fullfilled if the min quality is fullfilled
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
%     idsc = zeros(discretization.num_comb, 1);
%     fid = pc.model.file.st.fid;

import Optimization.Discrete.Models.write
%% write st values
fid = config.filehandles.st;
%%
loop_display(discretization.num_positions, 10);
write_log(' writing constraints...');

for idw = 1:discretization.num_positions
    %     for idw = 1:10
    %%
    wp_comb_ind = find(discretization.sc_wpn(:, idw));
    qvals = quality.wss.val{idw};    

    %%
    c_cnt = fprintf(fid, ' w%d_comb:', idw);
    write.tag_2value_lines(fid, ' +%0.4e s%ds%d',qvals , discretization.sc(wp_comb_ind,:), config.common.linesize, c_cnt, false);
    fprintf(fid, ' -w%d', idw);
    fprintf(fid, ' = 0\n');
    if mod(idw,discretization.num_positions/100)<1
        loop_display(idw);
    end
end
%%

return;
%% Tests
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;
%%%
config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality); 
%%
config = Configurations.Optimization.Discrete.bspqm;
Optimization.Discrete.Models.Constraints.sum_continuous(discretization, quality, config);

%%
figure, hold on;
sz = {3, 2};
subplot(sz{:},[1 2])
s_idx = 1:discretization.num_sensors;
plot(s_idx, cpx.Solution.x(s_idx), '.r');
subplot(sz{:}, [3 4])
c_idx = discretization.num_sensors+(1:discretization.num_comb);
plot(c_idx, cpx.Solution.x(c_idx), '.g');
subplot(sz{:},5)
w_idx = discretization.num_sensors+discretization.num_comb+(1:discretization.num_positions);
plot(w_idx, cpx.Solution.x(w_idx), '.b', 'MarkerSize', 20);
subplot(sz{:},6)
hold on;
boxplot(cpx.Solution.x(w_idx));

% plot(cpx.Solution.x(end-discretization.num_sensors-discretization.num_comb:end-discretization.num_sensors), '.g');
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