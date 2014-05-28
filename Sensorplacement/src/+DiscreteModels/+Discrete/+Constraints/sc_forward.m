function [ pc ] = sc_forward( pc )
%ADD_COMBINATIONS Summary of this function goes here
%   Detailed explanation goes here

[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
model_type = [model_prefix '_' model_name];
%%
if pc.progress.model.(model_type)
    pc = model.enable(pc, model_type);
    return;
end

if ~pc.progress.sensorspace.sensorcomb
    pc = sensorspace.sensorcomb(pc);
end

[pc] = model.init(pc, model_type);

%%
write_log(' adding combinations to model');
%% write constraints

% if pc.model.(model_type).obj.enable
    fid = pc.model.(model_type).obj.fid;
    %% write objective values
    %%
    %     loop_display(pc.problem.num_comb, 10);
    write_log(' writing obj function...');
    model.write.tag_value_lines(fid, ' +s%ds%d', pc.problem.sc_idx, pc.common.linesize);
    write_log('...done ');
% end
%% write constraints
%%% first part of and constrints
% -si2 + di1i2 <= 0
% two values per row and two equations
%  si_dij_lhs >= [si_dij_i, si_dij_j(l,r)]   <= si_dij_rhs
%                 Si1 ... Si2 .... di1i2
%  -inf       <= [ -1               1   ] <= 0
%  -inf       <= [        -1        1   ] <= 0
%%% second part of and constraints
% si1 si2 - di1i2 <= 1
% matrix representations has the form
% sij_dij_lhs <=[sij_dij_i,[pc.problem.sc_idx, sij_dij_j]]<= sij_dij_rhs
%                 Si1 ... Si2 .... di1i2
%  -inf        <= [ 1      1        -1   ] <= 1

% if pc.model.(model_type).st.enable
    fid = pc.model.(model_type).st.fid;
    %%
    loop_display(pc.problem.num_comb, 10);
    write_log(' writing constraints...');
    for idc = 1:pc.problem.num_comb
        %%
        sc_row = pc.problem.sc_idx(idc,:);
        fprintf(fid,['s%1$d_s%2$d_A: -s%1$d +s%1$ds%2$d <= 0\n'...
            's%1$d_s%2$d_B: -s%2$d +s%1$ds%2$d <= 0\n'...
            's%1$d_s%2$d_C: s%1$d +s%2$d -s%1$ds%2$d <= 1\n'],  sc_row(1), sc_row(2));
        if mod(idc,pc.problem.num_comb/1000)<1
            loop_display(idc);
        end
    end
    write_log('...done ');
% end
%
%
%% write Binaries
% if pc.model.(model_type).bin.enable
    fid = pc.model.(model_type).bin.fid;
    write_log(' writing obj function...');
    model.write.tag_value_lines(fid, ' s%ds%d', pc.problem.sc_idx, pc.common.linesize);
    
    write_log('...done ');
% end


%%
pc = model.finish(pc,model_type);
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
pc = model.wss.sensorcomb(pc);
%%%
pc = model.save(pc);
start_cplex(pc.model.lastsave);
s = read_solution(pc.model.lastsave);
draw.solution(pc, s);

