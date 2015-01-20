function [quality] = kirchhof(discretization, config)
% Loops through all relevant combinations and calculates the qualities for every workspace
% point. 
quality = DataModels.quality;

% [model_path, model_name] = fileparts(mfilename('fullpath'));
% model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
% quality_type = [model_prefix '_' model_name];

% write_log(' calculating %s quality values...', quality_type);
loop_display(discretization.num_positions, 10);

vals = cell(discretization.num_positions, 1);
valbw = zeros(discretization.num_comb, 1);
valsum = zeros(discretization.num_comb, 1);
%%
% dmax_2 = (config.sensor.distance(2)^2 );
dmax = config.sensor.distance(2);
dmax = 10000;
for idw = 1:discretization.num_positions
    %%
    idc = logical(discretization.sc_wpn(:, idw));
    s1_idx = discretization.sc(idc,1);
    s2_idx = discretization.sc(idc,2);
    %%
    q_sin = single(sin(mb.angle3PointsFast(discretization.sp(1:2, s1_idx), double(discretization.wpn(:,idw)), discretization.sp(1:2, s2_idx))))';    
    ds1 = mb.distancePoints(discretization.wpn(:,idw), discretization.sp(1:2, s1_idx));
    ds2 = mb.distancePoints(discretization.wpn(:,idw), discretization.sp(1:2, s2_idx));
    
    dn1 = ds1./dmax;
    dn2 = ds2./dmax;
    
%     vals{idw} = 1-(sqrt((ds1'.*ds2')./dmax_2)./(q_sin))./2;
    vals{idw} = 1-((dn1'.*dn2')./(q_sin));
    vals{idw}(vals{idw}<0) = 0;
    flt_vis = dn1>1|dn2>1;
    vals{idw}(flt_vis) = [];
    
    valsum(idc, 1) = sum(max(vals{idw},0)); 
    valbw(idc,1) = valbw(idc,1)+max(vals{idw}, 0);
    loop_display(idw);
end
%%
write_log('...done ');
quality.wss.val = vals;
quality.wss.valbw = valbw;
quality.wss.valsum = valsum;
%%

return;
%% TEST
discretization = [];
[X, Y] = meshgrid(0:100:16000, 10000:100:20000);
discretization.wpn = int64([X(:)'; Y(:)']);
discretization.sp = [5000, 13000; 10000, 10000];
discretization.num_positions = size(discretization.wpn, 2);
discretization.num_comb = 1;
discretization.sc = [1 2];
discretization.sc_wpn = uint8(ones(1, discretization.num_positions));
config.sensor.distance = [0 10000];
quality = Quality.WSS.kirchhof(discretization, config);

%%
cla
axis equal
qval = cell2mat(quality.wss.val);
scatter(single(discretization.wpn(1,:)'), single(discretization.wpn(2,:)'), [], repmat(qval, 1, 3));
xlim([5000 14000])
ylim([10000 18000])
%%
qmat = reshape(qval, size(X));
% figure;
axis equal
contour(X, Y, qmat, 0.1:0.1:0.9, 'ShowText','on');
xlim([0 16000]);
ylim([10000 20000]);
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

