%%
clearvars -except all_eval*

load tmp\small_flat\environment\environment.mat
input = Experiments.Diss.small_flat(500, 500);
sol200 = all_eval.small_flat.mspqm{21, 21};
input200 = Experiments.Diss.small_flat(200, 200);
wpn200 = input200.discretization.wpn;

basesolution = Evaluation.filter(sol200, input200.discretization);
inputbase = Experiments.Diss.small_flat(0, 0);
wpnbase = inputbase.discretization.wpn;

P_c = environment.P_c;
E_r = environment.E_r;
bpoly = environment.combined;
%%%
cla;
axis equal
hold on;
axis off
set(gcf, 'color', 'w')

sm = 5;
%%%
Environment.draw(input.environment, false);
mb.drawPolygon(environment.occupied, 'color', [0.6, 0.6, 0.6]);
fun_draw_edge = @(e) drawEdge(e, 'linewidth', 0.7, 'linestyle', ':', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);

mb.drawPoint(wpnbase, 'marker', '*', 'color', 0*ones(1,3), 'markersize', sm);
mb.drawPoint(wpn200, 'marker', '.', 'color', 0*ones(1,3), 'markersize', sm);

%%%
cmcqm_sol = all_eval.small_flat.cmcqm_cmaes_it{306};
cmcqm_sp = cmcqm_sol.solutions{end}.sp;
cmcqm_sp(3, :) = cmcqm_sp(3, :) + deg2rad(input.config.discretization.sensor.fov/2);
mb.drawPose(cmcqm_sp, 900, 'color', 0.75*ones(1,3), 'linewidth', 1, 'markersize', sm/2, 'marker', 'x', 'markerfacecolor', 0.5*ones(1,3));

cmqm_sol = all_eval.small_flat.cmqm_cmaes_it{561};
cmqm_sp = cmqm_sol.solutions{end-1}.sp;
cmqm_sp(3, :) = cmqm_sp(3, :) + deg2rad(input.config.discretization.sensor.fov/2);
mb.drawPose(cmqm_sp, 900, 'color', 0.5*ones(1,3), 'linewidth', 1, 'markersize', sm/2, 'marker', 'd', 'markerfacecolor', 0.5*ones(1,3));

base_sp_mid = basesolution.sp;
base_sp_mid(3, :) = base_sp_mid(3, :) + deg2rad(input.config.discretization.sensor.fov/2);
mb.drawPose(base_sp_mid, 600, 'color', 0*ones(1,3), 'linewidth', 1.5, 'markersize', sm, 'markerfacecolor', 'w');

for idv = 1:numel(basesolution.vfovs)
    mb.fillPolygon(basesolution.vfovs{idv}, 'k', 'facealpha', 0.1); 
end

mb.drawPoint(input200.discretization.sp(1:2,:), 'marker', 'o', 'color', 0.8*ones(1,3), 'markersize', sm/2, 'linewidth', 1.5);
mb.drawPoint(inputbase.discretization.sp(1:2, :), 'marker', 'o', 'color', 1*ones(1,3), 'markersize', sm/4, 'linewidth', 1.5);
%%%

axis equal

filename = 'DecomposedSmallFlat.tex';
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    ...         'height', '8cm',...
    'width', '9cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
    Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);

fprintf('Number of rpd parts %d\n', numel(input.parts));
fprintf('Number of wpn %d base %d 200 \n', size(wpnbase, 2), size(wpn200, 2));
fprintf('Initial number of cmqm sensors %d sp\n', cmqm_sol.all_sp+numel(cmqm_sol.solutions)-1);
fprintf('Sp: %d cmqm, %d cmcqm, %d mspqm\n', cmqm_sol.all_sp, cmcqm_sol.solutions{end}.discretization.num_sensors, basesolution.num_sensors);
fprintf('AllSp: %d base, %d 200\n', inputbase.discretization.num_sensors, input200.discretization.num_sensors);
fprintf('MeanMaxQ: %g cmqm,  %g mspqm\n', cmqm_sol.quality.sum_max/cmqm_sol.all_wpn, sol200.quality.sum_max/sol200.all_wpn);
fprintf('Area: %g cmqm, %g cmcqm, %g mspqm\n', cmqm_sol.quality.area_covered, 100*(1-cmcqm_sol.solutions{end}.fmin), sol200.quality.area_covered);
