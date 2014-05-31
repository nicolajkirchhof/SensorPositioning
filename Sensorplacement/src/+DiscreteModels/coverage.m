function pc = coverage(pc)
%%
[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
model_type = [model_prefix '_' model_name];
%%
if ~pc.progress.sensorspace.visibility
    pc = sensorspace.visibility(pc);
end
%%% if model was already in use, clear progress and re init
if pc.progress.model.(model_type)
    pc = model.enable(pc, model_type);
    return;
end


[pc] = model.init(pc, model_type);

%%
%% write objective values

fid = pc.model.(model_type).obj.fid;
%%
write_log(' starting coverage based lp file');
write_log(' obj...');
model.write.tag_value_lines(fid, ' +s%d', (1:pc.problem.num_sensors)', pc.common.linesize);
write_log('...done ');
%% write constraints
fid = pc.model.(model_type).st.fid;
%%
loop_display(pc.problem.num_positions, 10);
write_log(' writing constraints');
for idw = 1:pc.problem.num_positions
    % 16-22 chars
    c_cnt = fprintf(fid, ' k%d_wp%d_coverage:', pc.problem.k(idw), idw);
    % find all visible sensors
    s_idx = find(pc.problem.xt_ij(:,idw));
    if numel(s_idx) < pc.problem.k(idw)
        warning('model not solveable relaxing workspace point %d to %d ', idw, numel(s_idx));
        pc.problem.k(idw) = numel(s_idx);
    end
    model.write.tag_value_lines(fid, ' +s%d', s_idx(:), pc.common.linesize, c_cnt, false);
    fprintf(fid, ' >= %d\n', pc.problem.k(idw));
    if mod(idw,pc.problem.num_positions/100)<1
        loop_display(idw);
    end;
end
write_log('done ');
%% write Binaries

%%
% if pc.model.(model_type).bin.enable
    fid = pc.model.(model_type).bin.fid;
    loop_display(pc.problem.num_sensors, 10);
    write_log(' writing binaries...');
    model.write.tag_value_lines(fid, ' s%d', (1:pc.problem.num_sensors)', pc.common.linesize);
    write_log('...done ');
% end
%% write progress
[pc] = model.finish(pc, model_type);
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
pc = model.save(pc);
start_cplex(pc.model.lastsave);
s = read_solution(pc.model.lastsave);
draw.solution(pc, s);


