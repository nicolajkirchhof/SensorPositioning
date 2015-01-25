function sameplace(discretization, config)
% %%
import Optimization.Discrete.Models.write

    %% write constraints

    loop_display(discretization.num_sensors, 10);
    write_log(' adding two coverage constraint...');
    fid = config.filehandles.st;
    for ids = 1:discretization.num_sensors       
        if sum(discretization.spo(ids, :)) < 2
            % row can be neglected
            if config.common.debug
                write_log('row %d neglected since num sensors < 2', ids);
            end
            continue;
        end
        % 16-22 chars
        c_cnt = fprintf(fid, 'sprow%d:', ids);
        % find all visible sensors
        s_idx = find(discretization.spo(ids,:));
        write.tag_value_lines(fid, ' +s%d', s_idx(:), config.common.linesize, c_cnt, false);
        % close line if it has not been closed
        fprintf(fid, ' <= 1\n');
        if mod(ids,discretization.num_sensors/100)<1
            loop_display(ids);
        end;
        
    end
    write_log('...done ');
    

% pc.model.cplex.filename = [pc.model.cplex.filename '_sp'];
% pc = model.finish(pc, model_type);
% write_log('...done ');
return;

%% Tests
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality); 

config = Configurations.Optimization.Discrete.stcm;
%%
Optimization.Discrete.Models.Constraints.sameplace(discretization, config);





