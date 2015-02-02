% clear variables;
% % set(gca, 'CameraUpVector', [0 1 0]);
% 
% filename = 'res/floorplans/P1-Seminarraum.dxf';
% 
% env = Environment.load(filename);
% env.obstacles = {};
% env_comb = Environment.combine(env);
% bpoly = env_comb.combined;
% % bpoly = cellfun(@(x) circshift(x, -1, 1), bpoly, 'uniformoutput', false);
% num_sp = 0;
% num_wpn = 0;
% input = Experiments.Diss.conference_room(num_sp, num_wpn);
% [P_c, E_r] = mb.polygonConvexDecomposition(bpoly);

%% Add decomposition parts
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
name = names{4};
lookupdir = sprintf('tmp/%s/discretization/', name);
files = dir([lookupdir '*.mat']); 
loop_display(numel(files), 5);
%%%
for idf = 1:numel(files)
    file = files(idf);
    filename_full = [lookupdir file.name];
    input_all = load(filename_full);
    
    input = input_all.input;
    %%
    input.quality.wss = rmfield(input.quality.wss, {'valbw'; 'valsum'});
    input.quality = rmfield(input.quality, 'ws');
    input.discretization.spo = uint8(input.discretization.spo);
    input.discretization.vm = uint8(input.discretization.vm);
    input.discretization.spo_ids = cellfun(@(x) uint16(x), input.discretization.spo_ids, 'uniformoutput', false);
%     for idp = 1:numel(input.parts)
%         input.parts{idp} = rmfield(input.parts{idp}, {'config'; 'environment';'timestamp';'name'});
%         input.parts{idp}.quality = rmfield(input.parts{idp}.quality, 'ws');
%     end
    
    %%
    save(filename_full, 'input');
    
    loop_display(idf);
end


%% Add additional points
lookupdir = sprintf('tmp/conference_room/environment/');
files = dir([lookupdir '*.mat']); 
base_sensors = 130;
base_wpn = 20;
loop_display(numel(files), 5);
for idf = 1:numel(files)
    file = files(idf);
    input_all = load([lookupdir file.name]);
    %%
    input = input_all.input;
    
    add_sensors = input.discretization.num_sensors - base_sensors;
    add_sensors = floor(add_sensors/10)*10;
    add_wpn = input.discretization.num_positions - base_wpn;
    add_wpn = floor(add_wpn/10)*10;

    input.discretization.num_sensors_additional = add_sensors;
    input.discretization.num_positions_additional = add_wpn;
    
    save([lookupdir file.name], 'input');
    
    loop_display(idf);
end


%%
gco_dir = 'tmp\conference_room\gco';
files = dir('tmp\conference_room\gco\*.mat'); 

cnt = 0;
loop_display(numel(files), 5);
%%
for idf = 1:numel(files)
    %%
    file = files(idf);
    input_all = load([gco_dir filesep file.name]);
    vars = sscanf(file.name, 'gco__%d_%d_%d.mat');
    sp = vars(1);
    wpn = vars(2);

    add_sensors = sp - base_sensors;
    add_sensors = floor(add_sensors/10)*10;
    add_wpn = wpn - base_wpn;
    add_wpn = floor(add_wpn/10)*10;
    num_sp = add_sensors;
    num_wpn = add_wpn;
    
    
    input = input_all.input; 
    input.num_sp = num_sp;
    input.num_wpn = num_wpn;
    solution_filename = sprintf('gco__%d_%d.mat', num_sp, num_wpn);
    %%%
    save([gco_dir filesep solution_filename], 'input');
    %%
    
%     input.config = rmfield(input.config, 'optimization');
%     input = rmfield(input, 'solution');
%     

%     lookup_filename = sprintf('%d_%d.mat', add_sensors, add_wpn);
%     %%
%     save([lookupdir filesep lookup_filename], 'input');
%     %%
%     input = [];
%     input.solution = input_all.input.solution;
%     input.config.optimization = input_all.input.config.optimization;
%     %%
%     save([gco_dir filesep file.name], 'input');
%     
    cnt = cnt +1;
    loop_display(cnt);
end