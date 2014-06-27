function k_coverage(discretization, config)
% %%
% [model_path, model_name] = fileparts(mfilename('fullpath'));
% model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
% model_type = [model_prefix '_' model_name];
% %%
% if ~.progress.sensorspace.visibility
%      = sensorspace.visibility();
% end
% %%% if model was already in use, clear progress and re init
% if .progress.model.(model_type)
%      = model.enable(, model_type);
%     return;
% end
% 
% 
% [] = model.init(, model_type);
import Optimization.Discrete.Models.write
%%
loop_display(discretization.num_positions, 10);
write_log(' adding two coverage constraint...');
k = config.k;
fid = config.filehandles.st;
for idw = 1:discretization.num_positions
    % 16-22 chars
    c_cnt = fprintf(fid, ' k%d_wp%d_coverage:', k, idw);
    % find all visible sensors
    s_idx = find(discretization.vm(:,idw));
    write.tag_value_lines(fid, ' +s%d', s_idx(:), config.common.linesize, c_cnt, false);
    if numel(s_idx) >= k
        fprintf(fid, ' >= %d\n', k);
    else
        warning('model not solveable relaxing workspace point %d to %d ', idw, numel(s_idx));
%         discretization.k(idw) = numel(s_idx);
        fprintf(fid, ' >= %d\n', numel(s_idx));
    end
    
    if mod(idw,discretization.num_positions/100)<1
        loop_display(idw);
    end;
end
write_log('...done ');
%% write Binaries

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

config = Configurations.Optimization.Discrete.ssc;
Optimization.Discrete.Models.Constraints.k_coverage(discretization, config);



