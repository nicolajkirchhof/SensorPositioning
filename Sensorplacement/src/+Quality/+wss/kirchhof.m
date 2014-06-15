function [quality] = kirchhof(discretization, config)
% Loops through all relevant combinations and calculates the qualities for every workspace
% point. 
quality = DataModels.quality;

[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
quality_type = [model_prefix '_' model_name];


% quality_type = .quality.types.wss_dirdist;
% if ~.progress.sensorspace.sensorcomb
%      = sensorspace.sensorcomb();
% end
write_log(' calculating %s quality values...', quality_type);
% write_log('calculating directional quality values');
% num_comb = size(discretization.spc_idx, 1);
% q_sin = cell(discretization.num_sensors);
% calculate quality for every workspace point in every sensor combination
loop_display(discretization.num_positions, 10);
% for idc = 1:num_comb
    %%
%     s1_idx = discretization.spc_idx(idc,1);
%     s2_idx = discretization.spc_idx(idc,2);
%     w_idx = discretization.spc_wp_idx{idc};
%     q_sin{s1_idx, s2_idx} = single(sin(mb.angle3PointsFast(discretization.sp(1:2, s1_idx), discretization.wpn(1:2,w_idx), discretization.sp(1:2, s2_idx))))';
% end
vals = cell(discretization.num_positions, 1);
valbw = zeros(discretization.num_comb, 1);
valsum = zeros(discretization.num_comb, 1);
% dmax = (sensors.distance.max^2)/distance_factor;
% dopt = config.sensor.distance_optimal;
dmax_2 = (config.sensor.distance(2)^2 );
for idw = 1:discretization.num_positions
    %%
    idc = logical(discretization.sc_wpn(:, idw));
    s1_idx = discretization.sc(idc,1);
    s2_idx = discretization.sc(idc,2);
    %%
    q_sin = single(sin(mb.angle3PointsFast(discretization.sp(1:2, s1_idx), double(discretization.wpn(:,idw)), discretization.sp(1:2, s2_idx))))';    
    ds1 = mb.distancePoints(discretization.wpn(:,idw), discretization.sp(1:2, s1_idx));
    ds2 = mb.distancePoints(discretization.wpn(:,idw), discretization.sp(1:2, s2_idx));
    
%     qcust2 = 1-(repmat(((distances/dmax)).^2, num_angles, 1)./(sin(deg2rad(angs)))/2);
    vals{idw} = 1-(sqrt((ds1'.*ds2')./dmax_2)./(q_sin))./2;
% qcust2(qcust2 < 0) = -1;
%%
%     vals{idw} = q_sin./(1+(ds1.*ds2/dmax));
    valsum(idc, 1) = sum(max(vals{idw},0)); 
    valbw(idc,1) = valbw(idc,1)+vals{idw};
    loop_display(idw);
end
%%
write_log('...done ');
quality.wss.val = vals;
quality.wss.valbw = valbw;
quality.wss.valsum = valsum;


return;
%% TESTS
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
%
config_quality = Configurations.Quality.diss;
config = config_quality;
%%
[quality] = Quality.WSS.kirchhof(discretization, config_quality);

