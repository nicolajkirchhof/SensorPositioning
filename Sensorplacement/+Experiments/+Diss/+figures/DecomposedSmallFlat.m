%%
clearvars -except all_eval*
cla;
axis equal
hold on;
axis off



load tmp\small_flat\environment\environment.mat
input = Experiments.Diss.small_flat(500, 500);
sol200 = all_eval.small_flat.mspqm{21, 21};
basesolution = Evaluation.filter(sol200, input.discretization);
inputbase = Experiments.Diss.small_flat(0, 0);
wpnbase = inputbase.discretization.wpn;
input200 = Experiments.Diss.small_flat(200, 200);
wpn200 = input200.discretization.wpn;
P_c = environment.P_c;
E_r = environment.E_r;
bpoly = environment.combined;
%%%
cla
set(gcf, 'color', 'w')

sm = 5;
%%%
Environment.draw(input.environment, false);
mb.drawPolygon(environment.occupied, 'color', [0.6, 0.6, 0.6]);
% mb.drawPolygon(environment.mountable, 'color', [0.6, 0.6, 0.6]);
fun_draw_edge = @(e) drawEdge(e, 'linewidth', 0.7, 'linestyle', ':', 'color', [0 0 0]);
cellfun(@(x) fun_draw_edge(x.edge), E_r);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);
% mb.fillPolygon(input.environment.occupied, 0.5*ones(1,3));

mb.drawPoint(wpnbase, 'marker', '*', 'color', 0.7*ones(1,3), 'markersize', sm);
mb.drawPoint(wpn200, 'marker', '.', 'color', 0.7*ones(1,3), 'markersize', sm);

%%%
cmcqm_sp = all_eval.small_flat.cmcqm_cmaes_it{306};
cmcqm_sp = cmcqm_sp.solutions{end}.sp;
cmcqm_sp(3, :) = cmcqm_sp(3, :) + deg2rad(input.config.discretization.sensor.fov/2);
mb.drawPose(cmcqm_sp, 900, 'color', 0.8*ones(1,3), 'linewidth', 1, 'markersize', sm/2, 'marker', 'x', 'markerfacecolor', 0.5*ones(1,3));

base_sp_mid = basesolution.sp;
base_sp_mid(3, :) = base_sp_mid(3, :) + deg2rad(input.config.discretization.sensor.fov/2);
mb.drawPose(base_sp_mid, 600, 'color', 0*ones(1,3), 'linewidth', 1.5, 'markersize', sm, 'markerfacecolor', 'w');

mb.drawPoint(input200.discretization.sp(1:2,:), 'marker', 'o', 'color', 0.8*ones(1,3), 'markersize', sm/2, 'linewidth', 1.5);
mb.drawPoint(inputbase.discretization.sp(1:2, :), 'marker', 'o', 'color', 1*ones(1,3), 'markersize', sm/4, 'linewidth', 1.5);

fprintf('Sp: %d cmcqm, %d mspqm\n', size(cmcqm_sol.solutions{end-1}.sp, 2), basesolution.num_sensors);
fprintf('MeanMaxQ: %g mspqm\n', sol200.quality.sum_max/sol200.all_wpn);
fprintf('Area: %g cmcqm, %g mspqm\n', cmcqm_sol.solutions{end}.fmin, sol200.quality.area_covered);

axis equal
% axis on
% ylim([50 8600]);
% xlim([400 6100]);
        filename = 'DecomposedSmallFlat.tex';
    full_filename = sprintf('export/%s', filename);
        matlab2tikz(full_filename, 'parseStrings', false,...
...         'height', '8cm',...
        'width', '14cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    Figures.compilePdflatex(filename, true, true);
%     Figures.compilePdflatex(filename, false);
    
%     find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');