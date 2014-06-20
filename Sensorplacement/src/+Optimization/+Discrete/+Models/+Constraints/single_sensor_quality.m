function single_sensor_quality(discretization, quality, config)
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
% [s_1, s_2] = find(discretization.spo);
% s_ids = sortrows([s_1, s_2]);
% sc_spo_ids = s_ids(~(s_ids(:,1)==s_ids(:,2)), :);
spo_ids = discretization.spo_ids;

qmin = config.quality.min;
fid = config.filehandles.st;
for idw = 1:discretization.num_positions
    % 16-22 chars
    c_cnt = fprintf(fid, ' q%1.2f_wp%d_coverage:', qmin, idw);
    % find all visible sensors
    s_idx = find( discretization.vm(:,idw));
    s_idx_check = quality.ws.ids{idw};
    if ~(all(s_idx == s_idx_check))
        error('Ids do not match, something is wrong');
    end
       
    q_val = quality.ws.val{idw};
    write.tag_2value_lines(fid, ' +%e s%d', q_val(:), s_idx(:), config.common.linesize, c_cnt, false);
    
    %calc which sensors can not be combined
    [not_comb_sets not_comb_set_ids] = cellfun(@(s) intersect(s_idx, s), spo_ids, 'uniformoutput', false);
    [maxq] = cellfun(@(ids) min(q_val(ids)), not_comb_set_ids, 'uniformoutput', false);
    maxq_empty = cellfun(@isempty, maxq);
    
    q_max_pt = sum(cell2mat(maxq(~maxq_empty)))/2;
    if q_max_pt >= qmin
        fprintf(fid, ' >= %e \n', qmin);
    else
        warning('\n model not solveable relaxing quality of workspace point %d to %e \n', idw, q_max_pt);
%         discretization.k(idw) = numel(s_idx);
        fprintf(fid, ' >= %e \n', q_max_pt);
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

config = Configurations.Optimization.Discrete.mssqm;
%%
Optimization.Discrete.Models.Constraints.single_sensor_quality(discretization, quality, config);
% Optimization.Discrete.Models.Constraints.two_coverage(discretization, config);



