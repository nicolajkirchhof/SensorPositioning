function sc_ind( discretization, config )
%ADD_COMBINATIONS Summary of this function goes here
%   Detailed explanation goes here

%% write constraints
%%% first part of and constrints
% -si2 + di1i2 <= 0
% two values per row and two equations
%  si_dij_lhs >= [si_dij_i, si_dij_j(l,r)]   <= si_dij_rhs
%                 Si1 ... Si2 .... di1i2
%  -inf       <= [ 1                -1   ] >= 0
%  -inf       <= [         1        -1   ] >= 0
%%% second part of and constraints
% si1 si2 - di1i2 <= 1
% matrix representations has the form
% sij_dij_lhs <=[sij_dij_i,[pc.problem.sc_idx, sij_dij_j]]<= sij_dij_rhs
%                 Si1 ... Si2 .... di1i2
%  -inf        <= [ 1      1        -1   ] <= 1

fid = config.filehandles.st;
%%
loop_display(discretization.num_comb, 10);
write_log('writing constraints... ');
for idc = 1:discretization.num_comb
    %%
    sc_row = discretization.sc(idc,:);
%     fprintf(fid,'IFs%1$ds%2$dTHENs%1$d: s%1$ds%2$d = 1 -> s%1$d + s%2$d = 2\n',  sc_row(1), sc_row(2), idc);
    fprintf(fid,'IFs%1$ds%2$dTHENs%1$d: s%1$d -s%1$ds%2$d >= 0\n',  sc_row(1), sc_row(2), idc);
    fprintf(fid,'IFs%1$ds%2$dTHENs%2$d: s%2$d -s%1$ds%2$d >= 0\n',  sc_row(1), sc_row(2), idc);
    fprintf(fid,'IFs%1$dANDs%2$dTHENs%1$ds%2$d: s%1$d +s%2$d -s%1$ds%2$d <= 1\n',  sc_row(1), sc_row(2), idc);

    if mod(idc,discretization.num_comb/1000)<1
        loop_display(idc);
    end
end
write_log('...done ');

return;
%% testing
close all; clear all; fclose all;
pc = processing_configuration('sides4_nr0');
pc.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
pc.sensorspace.uniform_position_distance = 700;
pc.sensorspace.uniform_angle_distance = deg2rad(45);
pc.workspace.grid_position_distance = 700;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc = model.ws.coverage(pc);
%%%
pc = model.wss.sc_ind(pc);
%%
pc = model.save(pc);
cpx = solver.cplex.start(pc.model.lastsave);
draw.ws_solution(pc, cpx.Solution);

