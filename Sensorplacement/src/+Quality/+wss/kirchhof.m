function [quality] = kirchhof(discretization, config)
% Loops through all relevant combinations and calculates the qualities for every workspace
% point. 
quality = DataModels.quality;

[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
quality_type = [model_prefix '_' model_name];

write_log(' calculating %s quality values...', quality_type);
loop_display(discretization.num_positions, 10);

vals = cell(discretization.num_positions, 1);
valbw = zeros(discretization.num_comb, 1);
valsum = zeros(discretization.num_comb, 1);

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
    
    vals{idw} = 1-(sqrt((ds1'.*ds2')./dmax_2)./(q_sin))./2;

    valsum(idc, 1) = sum(max(vals{idw},0)); 
    valbw(idc,1) = valbw(idc,1)+max(vals{idw}, 0);
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

