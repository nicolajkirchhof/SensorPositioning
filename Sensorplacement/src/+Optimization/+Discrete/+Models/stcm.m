function model = stcm(discretization, quality, config)
%%
[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
model_type = [model_prefix '_' model_name];
% %%
% if ~.progress.sensorspace.visibility
%      = sensorspace.visibility();
% end
% %%% if model was already in use, clear progress and re init
% if .progress.model.(model_type)
%      = model.enable(, model_type);
%     return;
% end


[] = model.init(, model_type);

%%
%% write objective values

fid = .model.(model_type).obj.fid;
%%
write_log(' starting coverage based lp file');
write_log(' obj...');
model.write.tag_value_lines(fid, ' +s%d', (1:.problem.num_sensors)', .common.linesize);
write_log('...done ');
%% write constraints
fid = .model.(model_type).st.fid;
%%
loop_display(.problem.num_positions, 10);
write_log(' writing constraints');
for idw = 1:.problem.num_positions
    % 16-22 chars
    c_cnt = fprintf(fid, ' k%d_wp%d_coverage:', .problem.k(idw), idw);
    % find all visible sensors
    s_idx = find(.problem.xt_ij(:,idw));
    if numel(s_idx) < .problem.k(idw)
        warning('model not solveable relaxing workspace point %d to %d ', idw, numel(s_idx));
        .problem.k(idw) = numel(s_idx);
    end
    model.write.tag_value_lines(fid, ' +s%d', s_idx(:), .common.linesize, c_cnt, false);
    fprintf(fid, ' >= %d\n', .problem.k(idw));
    if mod(idw,.problem.num_positions/100)<1
        loop_display(idw);
    end;
end
write_log('done ');
%% write Binaries

%%
% if .model.(model_type).bin.enable
    fid = .model.(model_type).bin.fid;
    loop_display(.problem.num_sensors, 10);
    write_log(' writing binaries...');
    model.write.tag_value_lines(fid, ' s%d', (1:.problem.num_sensors)', .common.linesize);
    write_log('...done ');
% end
%% write progress
[] = model.finish(, model_type);
write_log('...done ');
return;
%% testing
close all; clear all; fclose all;
 = processing_configuration('sides4_nr0');
.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
.sensorspace.uniform_position_distance = 700;
.sensorspace.uniform_angle_distance = deg2rad(45);
.workspace.grid_position_distance = 700;
.sensors.distance.min = 0;
.sensors.distance.max = 6000;
 = model.ws.coverage();
 = model.save();
start_cplex(.model.lastsave);
s = read_solution(.model.lastsave);
draw.solution(, s);




