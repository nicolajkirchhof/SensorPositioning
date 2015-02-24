%% Add decomposition parts
clearvars;
name = 'office_floor';
lookupdir = sprintf('tmp/%s/mspqm/', name);
files = dir([lookupdir '*.sol']);
loop_display(numel(files), 5);
% mspqm_cr = cell(21, 21);
% mspqm_sf = cell(21, 21);
mspqm = cell(21, 21);
%%
for idf = 1:numel(files)
    %%
    file = files(idf);
    solfile = [lookupdir file.name];
    logfile = [lookupdir strrep(file.name, 'sol', 'log')];
    %%     outfile= [lookupdir strrep(file.name, 'sol', 'mat')];
    if exist(solfile, 'file') > 0
        %%
        solution = Optimization.Discrete.Solver.cplex.read_solution(solfile);
        solution.log = Optimization.Discrete.Solver.cplex.read_log(logfile);
        [A, cnt] = textscan(file.name, 'mspqm_%d_%[^_]_%[^_]_%d_%d.sol');
        solution.name = [A{2}{1} '_' A{3}{1}];
        solution.num_sensors_additonal = A{4};
        solution.num_positions_additional = A{5};
        input = Experiments.Diss.(solution.name)(solution.num_sensors_additonal, solution.num_positions_additional);
        [solution.discretization, solution.quality] = Evaluation.filter(solution, input.discretization, Configurations.Quality.diss);
        
        %%
        id_sp = solution.num_sensors_additonal/10 + 1;
        id_wpn = solution.num_positions_additional/10 + 1;
        mspqm{id_sp, id_wpn} = solution;
    end
    loop_display(idf);
end
%%
    save(sprintf('tmp/%s/mspqm.mat', name), 'mspqm');
    

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
