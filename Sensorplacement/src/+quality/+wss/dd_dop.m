function pc = dd_dop(pc, distance_factor)
% Loops through all relevant combinations and calculates the qualities for every workspace
% point. 
% distance_factor defines the influence of the distance on the quality function a distance_factor of
% one means that the angular quality is divided by two at the maximum distance. A distance factor of
% zero leads to a neglectance of the distance influence
%  

[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
quality_type = [model_prefix '_' model_name];

if nargin < 2
    warning('%s no distance scale was given, using 1', quality_type);
    distance_factor = 1;
end

% quality_type = 'wss_dd_dop';
%%%
if ~pc.progress.sensorspace.sensorcomb
    pc = sensorspace.sensorcomb(pc);
end

write_log(' calculating %s quality values...', quality_type);
%%
loop_display(pc.problem.num_positions, 10);
vals = cell(pc.problem.num_positions, 1);
valbw = zeros(pc.problem.num_comb, 1);
valsum = zeros(pc.problem.num_comb, 1);
dmax = (pc.sensors.distance.max^2)/distance_factor;
for idw = 1:pc.problem.num_positions
    %%
    idc = pc.problem.wp_sc_idx(:, idw);
    idc = logical(idc);
    s1_idx = pc.problem.sc_idx(idc,1);
    s2_idx = pc.problem.sc_idx(idc,2);
    %%
    q_sin = sin(mb.angle3PointsFast(pc.problem.S(1:2, s1_idx), pc.problem.W(:,idw), pc.problem.S(1:2, s2_idx)))';    
%     ds1 = mb.distancePoints(pc.problem.W(:,idw), pc.problem.S(1:2, s1_idx))';
    ds1 = sqrt(sum(bsxfun(@minus, pc.problem.S(1:2, s1_idx), pc.problem.W(:,idw)).^2, 1))';
%     ds2 = mb.distancePoints(pc.problem.W(:,idw), pc.problem.S(1:2, s2_idx))';
    ds2 = sqrt(sum(bsxfun(@minus, pc.problem.S(1:2, s2_idx), pc.problem.W(:,idw)).^2, 1))';
    %%
    % distance is mapped to 1-2
    vals{idw} = q_sin./(1+(ds1.*ds2/dmax));
    valsum(idc, 1) = sum(vals{idw}); 
    valbw(idc,1) = valbw(idc,1)+vals{idw};
    loop_display(idw);
end
%%
write_log('...done ');
pc.quality.(quality_type).val = vals;
pc.quality.(quality_type).valbw = valbw;
pc.quality.(quality_type).valsum = valsum;
pc.progress.quality.(quality_type) = true;

return;
%% testing
close all; clearvars all; fclose all; clear write_log
pc = processing_configuration('sides4_nr0');
pc.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
pc.sensorspace.uniform_position_distance = 100*5;
pc.sensorspace.uniform_angle_distance = deg2rad(45/2);
pc.workspace.grid_position_distance = 100*5;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
%%
pc = quality.wss.dd_dop(pc, 4);
figure, draw.wss_qstats(pc, pc.quality.types.wss_dd_dop);

% pc.model.wss_qclip.quality.min = 0.5;
% % pc.model.wss_qclip.quality.name = pc.quality.types.wss_dirdist;
% % pc.model.wss_qclip.quality.name = pc.quality.types.wss_distgeom;
% pc.model.wss_qclip.quality.name = pc.quality.types.wss_directional;
% pc.model.wss_qclip.obj.enable = false;
% pc.model.wss_qclip.bin.enable = false;
% pc = model.ws.coverage(pc);
% pc = model.wss.sc_backward(pc);
% % pc = model.wss.sensorcomb(pc);
% pc = model.wss.qclip(pc);
% %%%
% pc = model.save(pc);
% start_cplex(pc.model.lastsave);
% %%%
% figure,
% solution = read_solution(pc.model.lastsave);
% draw.wss_solution(pc, solution);
% draw.solution(pc, solution);