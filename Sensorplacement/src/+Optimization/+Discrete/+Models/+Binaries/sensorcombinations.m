function sensorcombinations(discretization, config)
%%



import Optimization.Discrete.Models.write
%%
write_log(' adding sensorcombinations binaries...');
fid = config.filehandles.bin;
write.tag_value_lines(fid, ' s%ds%d', discretization.sc, config.common.linesize);
% write.tag_value_lines(fid, ' s%d', (1:discretization.num_sensors)', config.common.linesize);
write_log('\n...done ');

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
Optimization.Discrete.Models.Binaries.sensorcombinations(discretization, config);


%%
% 
% [] = model.init(, model_type);
% 
% %%
% %% write objective values
% 
% fid = .model.(model_type).obj.fid;
% %%

% %% write constraints
% fid = .model.(model_type).st.fid;
% %%
% loop_display(.problem.num_positions, 10);
% write_log(' writing constraints');
% for idw = 1:.problem.num_positions
%     % 16-22 chars
%     c_cnt = fprintf(fid, ' k%d_wp%d_coverage:', .problem.k(idw), idw);
%     % find all visible sensors
%     s_idx = find(.problem.xt_ij(:,idw));
%     if numel(s_idx) < .problem.k(idw)
%         warning('model not solveable relaxing workspace point %d to %d ', idw, numel(s_idx));
%         .problem.k(idw) = numel(s_idx);
%     end
%     model.write.tag_value_lines(fid, ' +s%d', s_idx(:), .common.linesize, c_cnt, false);
%     fprintf(fid, ' >= %d\n', .problem.k(idw));
%     if mod(idw,.problem.num_positions/100)<1
%         loop_display(idw);
%     end;
% end
% write_log('done ');
% %% write Binaries
% 
% %%
% % if .model.(model_type).bin.enable
%     fid = .model.(model_type).bin.fid;
%     loop_display(.problem.num_sensors, 10);
%     write_log(' writing binaries...');
%     model.write.tag_value_lines(fid, ' s%d', (1:.problem.num_sensors)', .common.linesize);
%     write_log('...done ');
% % end
% %% write progress
% [] = model.finish(, model_type);
% write_log('...done ');
% return;
% %% testing
% close all; clear all; fclose all;
%  = processing_configuration('sides4_nr0');
% .environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
% .sensorspace.uniform_position_distance = 700;
% .sensorspace.uniform_angle_distance = deg2rad(45);
% .workspace.grid_position_distance = 700;
% .sensors.distance.min = 0;
% .sensors.distance.max = 6000;
%  = model.ws.coverage();
%  = model.save();
% start_cplex(.model.lastsave);
% s = read_solution(.model.lastsave);
% draw.solution(, s);
% 
% 
