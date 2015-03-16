%% Add decomposition parts
clearvars;
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
idn = 4;
name = names{idn};
% load(sprintf('tmp/%s.mat', name));
opt_name = 'bspqm_rpd';
lookupdir = sprintf('tmp/%s/', opt_name);
files = dir(sprintf('%s*%s*.mat', lookupdir, name));
loop_display(numel(files), 5);
bspqm_rpd = cell(51, 51);

%%
for idf = 1:numel(files)
    %%
    file = files(idf);
    matfile = [lookupdir file.name];
    load(matfile);
    solution = rmfield(solution, 'linearConstraints');
    solution = rmfield(solution, 'variables');
    solution = rmfield(solution, 'solvingtime');
    solution = rmfield(solution, 'env_points');
    solution = rmfield(solution, 'wpn_qualities');
    solution = rmfield(solution, 'env_qualities');
    %%
    id_sp = solution.num_sp/10 + 1;
    id_wpn = solution.num_wpn/10 + 1;
    input = Experiments.Diss.(name)(solution.num_sp, solution.num_wpn);
    sp_mapping = input.parts{solution.part}.discretization.sp_ids_mapping;
    sc_mapping = input.parts{solution.part}.discretization.sc_ids_mapping;
    %%
    parts = bspqm_rpd{id_sp, id_wpn};
    if isempty(parts)
       parts.solutions = {};
       parts.sensors_selected = [];
       parts.sc_selected = [];
    end
    parts.solutions{solution.part} = solution;
    sensors_selected = sp_mapping(solution.sensors_selected);
    parts.sensors_selected = unique([sensors_selected(:); parts.sensors_selected(:)]);
    sc_selected = sc_mapping(solution.sc_selected);
    parts.sc_selected = unique([sc_selected(:); parts.sc_selected(:)]);
    
    %%
    bspqm_rpd{id_sp, id_wpn} = parts;
    %     end
%     loop_display(idf);
end
%%
save(sprintf('tmp/%s/%s.mat', name, opt_name), opt_name);

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