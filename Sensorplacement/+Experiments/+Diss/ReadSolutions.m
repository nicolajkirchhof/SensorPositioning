%% Add decomposition parts
clear variables;
lookupdir = sprintf('tmp/small_flat/gcss/');
files = dir([lookupdir '*.mat']); 
loop_display(numel(files), 5);
gcss = cell(50, 50);
%%%
for idf = 1:numel(files)
    file = files(idf);    
    input_all = load([lookupdir file.name]);
    solution = input_all.input.solution;
    
    [A] = sscanf(file.name, 'gcss__%d_%d.mat');
    solution.num_sensors_additonal = A(1);
    solution.num_positions_additional = A(2);
    %%
    solution.wpn_qualities = solution.quality.wss.val;
    solution.wpn_qualities_max = cellfun(@max, solution.wpn_qualities);
    solution.num_sensors = solution.discretization.num_sensors;
    solution.num_positions = solution.discretization.num_positions;
    solution = rmfield(solution, {'quality'; 'discretization'});

    %%
    gcss{(A(1)/10)+1, (A(2)/10)+1} = solution;
    
    loop_display(idf);
end

%%
save tmp\small_flat\gcss\all.mat gcss

%%
%% Add decomposition parts
lookupdir = sprintf('tmp/conference_room/stcm/');
files = dir([lookupdir '*.mat']); 
loop_display(numel(files), 5);
stcm = cell(50, 50);
%%
for idf = 1:numel(files)
    file = files(idf);    
    input_all = load([lookupdir file.name]);
    solution = input_all.input.solution;
    
    [A] = sscanf(file.name, 'stcm__%d_%d.mat');
    solution.num_sensors_additonal = A(1);
    solution.num_positions_additional = A(2);
    %%
    solution.wpn_qualities = solution.quality.wss.val;
    solution.wpn_qualities_max = solution.discretization.wpn_qualities_max;
    solution.num_sensors = solution.discretization.num_sensors;
    solution.num_positions = solution.discretization.num_positions;
    solution = rmfield(solution, {'quality'; 'discretization'});

    %%
    stcm{(A(1)/10)+1, (A(2)/10)+1} = solution;
    
    loop_display(idf);
end
%%
save tmp\conference_room\stcm\all.mat stcm
