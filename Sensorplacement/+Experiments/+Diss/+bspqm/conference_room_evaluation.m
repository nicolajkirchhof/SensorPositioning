clear variables;
% close all;
% num_sp = 0:20:200
% num_wpns = 60:10:100;
% num_sps = 0:10:100;
% for id_wpn = 1:numel(num_wpns)
%     for id_sp = 1:numel(num_sps)
%         num_wpn = num_wpns(id_wpn);
%         num_sp = num_sps(id_sp);

%%
% % Calculate Discrete Models
dirname = 'tmp/conference_room/bspqm_qscale';
files = dir([dirname '/*.sol']);
%%
for idf = 1:numel(files)
    file = files(idf);
    matfile = [dirname filesep strrep(file.name, '.sol', '.mat')];
    solfile = [dirname filesep file.name];
    logfile = [dirname filesep strrep(file.name, '.sol', '.log')];
    input_all = load(matfile);
    input = input_all.input;
%     input = rmfield(input, 'solution');
    fields = fieldnames(input);

    %%
    if all(~strcmp(fields, 'solution'))
        log = Optimization.Discrete.Solver.cplex.read_log(logfile);
        solution = Optimization.Discrete.Solver.cplex.read_solution(solfile);
        input.log = log;
        input.solution = solution;
        for fn = fieldnames(input.log)'
            field = fn{1};
            input.solution.(field) = input.log.(field);
            
        end
        
        %%
        [input.solution.discretization, input.solution.quality] = Evaluation.filter(input.solution, input.discretization, input.config.quality);
        input.solution.discretization.wpn_qualities_max = cellfun(@max, input.solution.quality.wss.val );
        
        %%
        save(matfile, 'input');
    end
    
end


%% Plot solutions
clear variables;
dirname = 'tmp/conference_room/bspqm';
% dirname = 'tmp/conference_room/bspqm_qscale';
files = dir([dirname '/*.sol']);
idf = 1;
input = cell(1, numel(files));
%%%
for idf = 1:numel(files)
    file = files(idf);
    matfile = [dirname filesep strrep(file.name, '.sol', '.mat')];
    input_all = load(matfile);
    input{idf} = input_all.input;
end
bspqm = input;

%% Plot solutions
% clear variables;
% bspqm_dirname = 'tmp/conference_room/bspqm';
dirname = 'tmp/conference_room/bspqm_qscale';
files = dir([dirname '/*.sol']);
idf = 1;
input = cell(1, numel(files));
%%%
for idf = 1:numel(files)
    file = files(idf);
    matfile = [dirname filesep strrep(file.name, '.sol', '.mat')];
    input_all = load(matfile);
    input{idf} = input_all.input;
end
bspqm_qscale = input;
%% Same WPN
wpn_found = [];
wpn_ids = {};
%%%%
for id = 1:numel(input);
    %%
    num_pos = input{id}.discretization.num_positions;
    id_found = find(wpn_found == num_pos);
    if ~isempty(id_found)
        wpn_ids{id_found} = [wpn_ids{id_found} id];
    else
        wpn_found = [wpn_found num_pos];
        wpn_ids{end+1} = id;
    end
    
    
end

[wpn_found, ids_sort] = sort(wpn_found);
wpn_ids = wpn_ids(ids_sort);

%%
close all;
size = [325 420];
pos = [0 0];
for id_set = 1:numel(wpn_ids);
    for id_input = 1:numel(wpn_ids{id_set})
        id = wpn_ids{id_set}(id_input);
        figure;
        Discretization.draw(input{id}.solution.discretization, input{id}.environment);
        hold on;
        Discretization.draw_wpn_max_qualities(input{id}.solution.discretization, input{id}.solution.quality);
        Discretization.draw_vfos(input{id}.discretization, input{id}.solution);
        allqvall = cell2mat(input{id}.solution.quality.wss.val);
        title(sprintf('Num SP %d, Sel SP %d, Num WPN %d\n MinQ %.4g, MaxQ %.4g,\n Mean/dQ %.4g %.4g SumQ %.4g ',... 
            input{id}.discretization.num_sensors, input{id}.solution.discretization.num_sensors, input{id}.discretization.num_positions,...
            min(allqvall), max(allqvall), mean(allqvall), median(allqvall), sum(allqvall)));
        set(gcf, 'Position', [pos size]);
        pos(1) = pos(1)+325;
        if pos(1) > 1590
            pos = [0 500];
        end
    end
    pause
end

%% Calculate all wpn qualities values
wpn_qualities = zeros(




% cellfun(@mb.drawPolygon, input{id_input}.solution.discretization.vfovs);
% g

