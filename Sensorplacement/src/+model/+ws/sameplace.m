function pc = sameplace(pc)
%%
[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
model_type = [model_prefix '_' model_name];
%%
if pc.progress.model.(model_type)
    pc = model.enable(pc, model_type);
    return;
end

if ~pc.progress.sensorspace.sameplace
    pc = sensorspace.sameplace(pc);
end

[pc] = model.init(pc, model_type);


%%

    write_log(' adding %s constraints', model_type);
    %% write constraints

    fid = pc.model.(model_type).st.fid;
    %%
    loop_display(pc.problem.num_positions, 10);
    write_log(' writing constraints ');
    for ids = 1:pc.problem.num_sensors
        if sum(pc.problem.sp_ij(ids, :)) < 2
            % row can be neglected
            if pc.common.debug
                write_log('row %d neglected since num sensors < 2', ids);
            end
            continue;
        end
        % 16-22 chars
        c_cnt = fprintf(fid, 'sprow%d:', ids);
        % find all visible sensors
        s_idx = find(pc.problem.sp_ij(ids,:));
        model.write.tag_value_lines(fid, ' +s%d', s_idx(:), pc.common.linesize, c_cnt, false);
        % close line if it has not been closed
        fprintf(fid, ' <= 1\n');
        if mod(ids,pc.problem.num_positions/100)<1
            loop_display(ids);
        end;
        
    end
    write_log('...done ');
    

% pc.model.cplex.filename = [pc.model.cplex.filename '_sp'];
pc = model.finish(pc, model_type);
write_log('...done ');
return;

%% testing
close all; clear all; fclose all;
pc = processing_configuration('sides4_nr0');
pc.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
pc.sensorspace.uniform_position_distance = 600;
pc.sensorspace.uniform_angle_distance = deg2rad(45);
pc.workspace.grid_position_distance = 600;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc = model.ws.coverage(pc);
%%
pc = model.ws.sameplace(pc);
%%
pc = model.save(pc);
start_cplex(pc.model.lastsave);
s = read_solution(pc.model.lastsave);
draw.solution(pc, s);





