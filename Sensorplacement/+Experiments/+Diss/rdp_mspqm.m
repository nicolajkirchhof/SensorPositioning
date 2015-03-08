%%
clear variables;
% bpoly = cellfun(@(x) circshift(x, -1, 1), bpoly, 'uniformoutput', false);
%%
close all;
clearvars;
%%
% num_sp = 0:20:200
% num_wpns = 0:10:50;
names = {'small_flat', 'large_flat', 'office_floor'};
% names = {'large_flat'};
% names = {'office_floor'}

% num_wpns = 0:10:200;
num_wpns = 0:50:500;
num_sps =  0:50:500;

%%
iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps)*numel(names);
%%%
% gco = cell(numel(num_sps), numel(num_wpns));
for id_n = 1:numel(names)
    name = names{id_n};
    for id_wpn = 1:numel(num_wpns)
        for id_sp = 1:numel(num_sps)
            num_wpn = num_wpns(id_wpn);
            num_sp = num_sps(id_sp);
            
            %%
            %         num_wpn = 0;
            %         num_sp = 50;
            
            input = Experiments.Diss.(name)(num_sp, num_wpn);% true);
            
            for idpt = 1:numel(input.parts)
                if input.parts{idpt}.discretization.num_positions > 0
                    gen = Configurations.Common.generic();
                    gen.workdir = sprintf('tmp/mspqm_rpd');
                    bspqm_config = Configurations.Optimization.Discrete.bspqm(gen);
                    bspqm_config.name = sprintf('%04d_%s_%02d', iteration, name, idpt);
                    
                    filename = Optimization.Discrete.Models.bspqm(input.parts{idpt}.discretization, input.parts{idpt}.quality, bspqm_config);
                    %         filename_new = strrep(filename, '.lp', sprintf('p%d.lp', idpt));
                    %         movefile(filename, filename_new);
                end
            end
            
            
            iteration = iteration + 1;
            if toc(tme)>next
                fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
                next = toc(tme)+stp;
            end
        end
    end
end

%%


%%
cplex = [getenv('home') '\App\Cplex\cplex\bin\x64_win64\cplex.exe'];

cnt = 0;
for idpt = 1:numel(input.parts)
    if input.parts{idpt}.discretization.num_positions > 0
        gen = Configurations.Common.generic();
        gen.workdir = sprintf('tmp/bspqm_rdp');
        bspqm_config = Configurations.Optimization.Discrete.bspqm(gen);
        bspqm_config.name = sprintf('%03d_%s_%02d', cnt, name, idpt);
        
        filename = Optimization.Discrete.Models.bspqm(input.parts{idpt}.discretization, input.parts{idpt}.quality, bspqm_config);
        %         filename_new = strrep(filename, '.lp', sprintf('p%d.lp', idpt));
        %         movefile(filename, filename_new);
    end
end

%%
outputdir = 'tmp\bspqm_rdp';
files = dir([outputdir '\*.lp']);

solutions = cell(numel(files), 1);
for idf = 1:numel(files)
    filename = [outputdir filesep files(idf).name];
    [A, cnt] = textscan(files(idf).name, 'bspqm_%d_%[^_]_%[^_]_%d_%d_%d.sol');
    
    
    solution = [];
    solution.part = A{4};
    solution.num_sp = A{5};
    solution.num_wpn = A{6};
    
    [solution.solfile, solution.logfile] = Optimization.Discrete.Solver.cplex.start(filename, cplex);
    solution.log = Optimization.Discrete.Solver.cplex.read_log(solution.logfile);
    solution.solution = Optimization.Discrete.Solver.cplex.read_solution(solution.solfile);
    
    solutions{idf} = solution;
end

%%
solution = [];
solution.sensors_selected = [];
solution.sc_selected = [];
solution.wpn_qualities = [];

for idip = 1:numel(solutions)
    id_part = solutions{idip}.part;
    sp_sel = input.parts{id_part}.discretization.sp_ids_mapping(solutions{idip}.solution.sensors_selected);
    solution.sensors_selected = [solution.sensors_selected; sp_sel(:)];
    %     solution.sc_selected = [solution.sc_selected input.parts{idip}.discretization.sp_ids_mapping(unique(solutions{idip}.solution.sc_selected(:))')];
    wpn_ids = input.parts{id_part}.discretization.wpn_ids_mapping;
    solution.wpn_qualities(wpn_ids) = solutions{idip}.solution.wpn_qualities;
end
%%
cla;
axis equal
axis off
hold on
fun_draw_edge = @(e) drawEdge(e, 'linewidth', 1, 'linestyle', '--', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);

% axis on
ylim([250 3900]);
xlim([1150 8400]);