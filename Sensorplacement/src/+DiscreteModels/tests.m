%% tests all models 
close all; clear all; fclose all;
pc = processing_configuration('sides4_nr0');
pc.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
pc.sensorspace.uniform_position_distance = 600;
pc.sensorspace.uniform_angle_distance = deg2rad(45);
pc.workspace.grid_position_distance = 600;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;


[model_path, model_name] = fileparts(mfilename('fullpath'));
ws_path = [model_path filesep '+ws'];
wss_path = [ws_path 's'];
ws_model_files = dir([ws_path filesep '*.m']);
wss_model_files = dir([wss_path '+wss' filesep '*.m']);

%% iterative tests
for wsm = 1:numel(ws_model_files)
    pctst = model.ws.(ws_model_files(wsm).name(1:end-2))(pc);
    pctst = model.save(pctst);
    start_cplex(pctst.model.lastsave);
end
%%
for wssm = 1:numel(wss_model_files)
    pctst = model.wss.(wss_model_files.name(1:end-2))(pc);
    pctst = model.save(pctst);
    start_cplex(pctst.model.lastsave);
end
