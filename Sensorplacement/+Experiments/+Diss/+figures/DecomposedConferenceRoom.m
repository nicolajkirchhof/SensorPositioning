%%
clearvars -except all_eval*
cla;
axis equal
hold on;
axis off

input = Experiments.Diss.conference_room(500, 500);
sol200 = all_eval.conference_room.mspqm{21, 21};
basesolution = Evaluation.filter(sol200, input.discretization);
inputbase = Experiments.Diss.conference_room(0, 0);
wpnbase = inputbase.discretization.wpn;
input200 = Experiments.Diss.conference_room(200, 200);
wpn200 = input200.discretization.wpn;
bpoly = input.environment.combined;

%%%
environment = input.environment;
cla
set(gcf, 'color', 'w')

sm = 7;
%%%
Environment.draw(input.environment, false);
mb.drawPolygon(environment.occupied, 'color', [0.6, 0.6,  0.6], 'linewidth', 2);
fun_draw_edge = @(e) drawEdge(e, 'linewidth', 0.7, 'linestyle', ':', 'color', [0 0 0]);
mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);

mb.drawPoint(wpnbase, 'marker', '*', 'color', 0.7*ones(1,3), 'markersize', sm);
mb.drawPoint(wpn200, 'marker', '.', 'color', 0.7*ones(1,3), 'markersize', sm);

%%%
cmqm_sol = all_eval.conference_room.cmqm_cmaes_it{306};
cmqm_sp = cmqm_sol.solutions{end-1}.sp;
cmqm_sp(3, :) = cmqm_sp(3, :) + deg2rad(input.config.discretization.sensor.fov/2);
mb.drawPose(cmqm_sp, 900, 'color', 0.5*ones(1,3), 'linewidth', 1, 'markersize', sm/2, 'marker', 'd', 'markerfacecolor', 0.5*ones(1,3));

cmcqm_sol = all_eval.conference_room.cmcqm_cmaes_it{306};
cmcqm_sp = cmcqm_sol.solutions{end-1}.sp;
cmcqm_sp(3, :) = cmcqm_sp(3, :) + deg2rad(input.config.discretization.sensor.fov/2);
mb.drawPose(cmcqm_sp, 900, 'color', 0.8*ones(1,3), 'linewidth', 1, 'markersize', sm, 'marker', 'x', 'markerfacecolor', 0.5*ones(1,3));

base_sp_mid = basesolution.sp;
base_sp_mid(3, :) = base_sp_mid(3, :) + deg2rad(input.config.discretization.sensor.fov/2);
mb.drawPose(base_sp_mid, 600, 'color', 0*ones(1,3), 'linewidth', 1.5, 'markersize', sm, 'markerfacecolor', 'w');

mb.drawPoint(input200.discretization.sp(1:2,:), 'marker', 'o', 'color', 0.8*ones(1,3), 'markersize', sm/2, 'linewidth', 1.5);
mb.drawPoint(inputbase.discretization.sp(1:2, :), 'marker', 'o', 'color', 1*ones(1,3), 'markersize', sm/4, 'linewidth', 1.5);

axis equal

fprintf('Sp: %d cmqm, %d cmcqm, %d mspqm\n', cmqm_sol.all_sp, size(cmcqm_sol.solutions{end-1}.sp, 2), basesolution.num_sensors);
fprintf('MeanMaxQ: %g cmqm,  %g mspqm\n', cmqm_sol.quality.sum_max/cmqm_sol.all_wpn, sol200.quality.sum_max/sol200.all_wpn);
fprintf('Area: %g cmqm, %g cmcqm, %g mspqm\n', cmqm_sol.quality.area_covered, cmcqm_sol.solutions{end}.fmin, sol200.quality.area_covered);

%%%
filename = 'DecomposedConferenceRoom.tex';
    full_filename = sprintf('export/%s', filename);
        matlab2tikz(full_filename, 'parseStrings', false,...
...         'height', '8cm',...
        'width', '14cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);