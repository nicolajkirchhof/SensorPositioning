function solution = bspqm( solution )
%BSPQM Generates all plots for the best sensor pairwise quality model
% colormap(cmap); 
% surf(X,Y,Z, colors);
% axis([-3 3 -3 3 -10 10]);
% 
% cbh = colorbar('YGrid','on');
% set(cbh,'ytick',linspace(1,3,4));
% set(cbh,'yticklabel',arrayfun(@num2str,[minval -crange crange maxval],'uni',false));
% 
% cla
close all;
num_steps = 10;
Environment.draw(solution.environment);
cmap = repmat(linspace(0, 0.8, num_steps), 3, 1)';
title(sprintf('Solution with %d choosen Sensors', numel(sol.sensor.ids)));
hold on;
hBoundary = mb.drawPolygon(discretization.vfovs(sol.sensor.ids), 'color', [0.2 0.2 0.2]);
%     hBoundary = hBoundary(1);
%     set(get(get(hBoundary,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
%
hPt = drawPoint(discretization.sp(1:2, sol.sensor.ids)', 'color', [0.7 0.7 0.7], 'marker', 'o', 'markersize', 10, 'markerfacecolor',  [0.2 0.2 0.2], 'markeredgecolor', 'w');
    set(get(get(hPt,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
for idx = 1:numel(sol.sensor.ids)
    idsol = sol.sensor.ids(idx);
    sensor_middle_angle = discretization.sp(3,idsol)+deg2rad(solution.config.discretization.sensor.fov/2);
    line = [discretization.sp(1:2, idsol)', cos(sensor_middle_angle), sin(sensor_middle_angle)];
    edge = createEdge(line, 500);
    
    drawEdge(edge, 'color', [0.5 0.5 0.5], 'lineWidth', 2 );%, 'marker', 'p', 'markersize', 5, 'markerfacecolor',  colors(idx, :));
end
%
scatter(discretization.wpn(1,:)', discretization.wpn(2,:), 5, solution.solution.wpn_qualities, 'filled');
colormap(cmap);
cbh  = colorbar;
% cbh = colorbar('YGrid','on');
qmin = min(solution.solution.wpn_qualities);
qmax = max(solution.solution.wpn_qualities);
qticks = qmin:solution.config.model.quality.min:qmax;
set(cbh,'ytick', qticks);
set(cbh,'yticklabel',arrayfun(@(x) sprintf('%dqmin', x),1:numel(qticks),'uni',false));
%%
qmin = solution.config.model.quality.min;
figure; hold on;
bar(solution.solution.wpn_qualities);
line(xlim, [qmin qmin], 'color', [0.6 0.6 0.6]);
