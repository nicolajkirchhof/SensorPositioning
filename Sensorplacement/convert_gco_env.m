%%
lookupdir = sprintf('tmp/conference_room/environment');
gco_dir = 'tmp\conference_room\gco';
files = dir('tmp\conference_room\gco\*.mat'); 
base_sensors = 130;
base_wpn = 20;
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