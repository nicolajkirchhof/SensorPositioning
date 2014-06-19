function sameplace(discretization, config)
% %%
% [model_path, model_name] = fileparts(mfilename('fullpath'));
% model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
% model_type = [model_prefix '_' model_name];
% %%
% if pc.progress.model.(model_type)
%     pc = model.enable(pc, model_type);
%     return;
% end
% 
% if ~pc.progress.sensorspace.sameplace
%     pc = sensorspace.sameplace(pc);
% end
% 
% [pc] = model.init(pc, model_type);


%%
import Optimization.Discrete.Models.write
%%
% loop_display(discretization.num_positions, 10);
% write_log(' adding two coverage constraint...');
% k = 2;
% fid = config.filehandles.st;
% for idw = 1:discretization.num_positions
%     % 16-22 chars
%     c_cnt = fprintf(fid, ' k%d_wp%d_coverage:', k, idw);
%     % find all visible sensors
%     s_idx = find(discretization.vm(:,idw));
%     write.tag_value_lines(fid, ' +s%d', s_idx(:), config.common.linesize, c_cnt, false);
%     if numel(s_idx) >= k
%         fprintf(fid, ' >= %d\n', k);
%     else
%         warning('model not solveable relaxing workspace point %d to %d ', idw, numel(s_idx));
% %         discretization.k(idw) = numel(s_idx);
%         fprintf(fid, ' >= %d\n', numel(s_idx));
%     end
%     
%     if mod(idw,discretization.num_positions/100)<1
%         loop_display(idw);
%     end;
% end
% write_log('...done ');

%     write_log(' adding %s constraints', model_type);
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





