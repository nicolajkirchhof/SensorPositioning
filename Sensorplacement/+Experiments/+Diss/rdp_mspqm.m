%%
clear variables;
% bpoly = cellfun(@(x) circshift(x, -1, 1), bpoly, 'uniformoutput', false);
%%
num_sp = 0;
num_wpn = 0;
name = 'small_flat';
input = Experiments.Diss.small_flat(num_sp, num_wpn);
[P_c, E_r] = mb.polygonConvexDecomposition(input.environment.combined);

input.parts = Environment.filter(input, P_c);
P_c = cellfun(@(x) mb.visilibity2boost(x), P_c, 'uniformoutput', false);

%%
cplex = [getenv('home') '\App\Cplex\cplex\bin\x64_win64\cplex.exe'];

cnt = 0;
for idpt = 1:numel(parts)
    if parts{idpt}.discretization.num_positions > 0
            gen = Configurations.Common.generic();
            gen.workdir = sprintf('tmp/bspqm_rdp');
            bspqm_config = Configurations.Optimization.Discrete.bspqm(gen);
            bspqm_config.name = sprintf('%03d_%s_%02d', cnt, name, idpt);

            filename = Optimization.Discrete.Models.bspqm(parts{idpt}.discretization, parts{idpt}.quality, bspqm_config);
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
    solution.sensors_selected = [solution.sensors_selected solutions{idip}.solution.sensors_selected];
    solution.sc_selected = [solution.sc_selected unique(solutions{idip}.solution.sc_selected(:))'];
    wpn_ids = input.parts{solutions{idip}.part}.discretization.wpn_ids_mapping;
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