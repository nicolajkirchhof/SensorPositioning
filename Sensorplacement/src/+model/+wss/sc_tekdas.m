function [ pc ] = sc_tekdas( pc )
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

% if ~pc.progress.sensorspace.sensorcomb
%     pc = sensorspace.sensorcomb(pc);
% end

qname = pc.model.(model_type).quality.name;
if ~pc.progress.quality.(qname)
    pc = pc.quality.(qname).fct(pc, pc.model.(model_type).quality.param);
end

[pc] = model.init(pc, model_type);

%%
write_log(' adding combinations to model...');
%% write constraints

fid = pc.model.(model_type).obj.fid;
bfid = pc.model.(model_type).bin.fid;
%% write objective values
%%
%     loop_display(pc.problem.num_comb, 10);
write_log(' writing obj function...');
% model.write.tag_value_lines(fid, ' +s%ds%d', pc.problem.sc_idx, pc.common.linesize);
model.write.tag_value_lines(fid, ' +s%d', (1:pc.problem.num_sensors)', pc.common.linesize);
model.write.tag_value_lines(bfid, ' s%d', (1:pc.problem.num_sensors)', pc.common.linesize);
write_log('...done ');
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

fid = pc.model.(model_type).st.fid;
%%
loop_display(pc.problem.num_comb, 10);
write_log(' writing constraints...');
for idp = 1:pc.problem.num_positions
   wp_comb_ind = find(pc.problem.wp_sc_idx(:, idp));
   qvals = pc.quality.(pc.model.(model_type).quality.name).val{idp};
   wp_comb_flt = (qvals > pc.model.(model_type).quality.min);
%    num_pairs = 1;
   if isempty(wp_comb_flt)
        error('model not solveable');
   end
    
    fltwp = logical(pc.problem.wp_sc_idx(:,idp));
    % set all comb that do not fulfill the quality to zero
    fltwp(wp_comb_ind(~wp_comb_flt)) = 0;
    for idc = find(fltwp)'
        fprintf(fid,'x%1$d_%2$d_%3$dANDs%2$d: s%2$d - x%1$d_%2$d_%3$d >= 0\n',  idp, pc.problem.sc_idx(idc, 1),pc.problem.sc_idx(idc, 2) );
        fprintf(fid,'x%1$d_%2$d_%3$dANDs%3$d: s%3$d - x%1$d_%2$d_%3$d >= 0\n',  idp, pc.problem.sc_idx(idc, 1),pc.problem.sc_idx(idc, 2) );
    end
    wp_comb = pc.problem.sc_idx(fltwp,:);
    ids_sensors = unique(pc.problem.sc_idx(fltwp,:));

    fprintf(fid, 'Sumz%d:',  idp);
    wp_string = sprintf(' +z%d_%%d', idp);
    model.write.tag_value_lines(fid, wp_string, ids_sensors, pc.common.linesize);
    fprintf(fid, ' = 2\n');
    %% write binaries
    wp_string = sprintf(' z%d_%%d', idp);
    model.write.tag_value_lines(bfid, wp_string, ids_sensors, pc.common.linesize);
    wp_string = sprintf(' x%d_%%d_%%d', idp);
    model.write.tag_2value_lines(bfid, wp_string, wp_comb(:,1), wp_comb(:,2), pc.common.linesize);

    %%
    for ids = ids_sensors(:)'
        flt_wp_comb = wp_comb(:,1)==ids|wp_comb(:,2)==ids;
        fprintf(fid,'Sum_z%d_%d:',  idp, ids);
        wp_string= sprintf(' +x%d_%%d_%%d', idp);
        model.write.tag_2value_lines(fid, wp_string, wp_comb(flt_wp_comb,1), wp_comb(flt_wp_comb,2), pc.common.linesize);
        fprintf(fid,' - z%d_%d = 0\n', idp, ids);    
    end
    
end
%%
% for idp = 1:pc.problem.num_positions
%     fprintf(fid,'SumZ%d:',  idp);
%     model.write.tag_2value_lines(fid, ' +z%d_%d', ones(pc.problem.num_sensors,1)*idp, (1:pc.problem.num_sensors)', pc.common.linesize);
%     fprintf(fid,' = 2\n');
% end
% %%
% for idc = 1:pc.problem.num_comb
%     %%
%     sc_row = pc.problem.sc_idx(idc,:);
%     fprintf(fid,'IFs%1$ds%2$dTHENs%1$d: s%1$d -s%1$ds%2$d >= 0\n',  sc_row(1), sc_row(2), idc);
%     fprintf(fid,'IFs%1$ds%2$dTHENs%2$d: s%2$d -s%1$ds%2$d >= 0\n',  sc_row(1), sc_row(2), idc);
%     if mod(idc,pc.problem.num_comb/1000)<1
%         loop_display(idc);
%     end
% end
write_log('...done ');
%
%
%% write Binaries
% fid = pc.model.(model_type).bin.fid;
% write_log(' writing obj function...');
% model.write.tag_value_lines(fid, ' s%ds%d', pc.problem.sc_idx, pc.common.linesize);

% write_log('...done ');


%%
pc = model.finish(pc,model_type);
write_log('...done ');
return;
%% testing
close all; clear all; fclose all;
supd = 800;
wgpd = 800;
suad = deg2rad(45);
pc = processing_configuration(sprintf('rectangular_room-supd%d-wgpd%d-suad%d', supd, wgpd, round(rad2deg(suad))));
% pc.environment.file = 'res/floorplans/P1-Pool.dxf';
pc.environment.file = 'res/env/rectangular_room.environment';
% pc = processing_configuration('sides4_nr0');
% pc.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
pc.sensorspace.uniform_position_distance = supd;
pc.sensorspace.uniform_angle_distance = suad;
pc.workspace.grid_position_distance = wgpd;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc = workspace.positions(pc);
draw.workspace(pc);
%%
model_type  = pc.model.types.wss_sc_tekdas;
pc.model.(model_type).quality.param = 5;
pc.model.(model_type).quality.name = pc.quality.types.wss_dd_dop;
pc.model.(model_type).quality.min = 0.3;
pc = model.wss.sc_tekdas(pc);
% pc.model.(model_type).enable = false;

%
pc = model.save(pc);
%%
sol = solver.cplex.startext(pc.model.lastsave);
% if ~isempty(cpx.Solution)
    %     draw.solution(pc, cpx.Solution);
    draw.ws_solution_parsed(pc, sol);
%     draw.ws_wp_solstats(pc, cpx.Solution);
% end

