function workspace_qualities(pc, solution)
%%
solution_ids = find(solution.x(1:pc.problem.num_sensors));
colors =  hsv(numel(solution_ids));
color_ids = randperm(numel(solution_ids));
colors = colors(color_ids, :);
cla;
title(sprintf('Solution with %d choosen Sensors', sum(solution.x(1:pc.problem.num_sensors))));
% draw.workspace(pc);
% hold on;
% for idx = 1:numel(solution_ids)
%     idsol = solution_ids(idx);
% %     disp(polyarea(pc.problem.V{1,idsol}.x, pc.problem.V{1,idsol}.y));
%     hFill = mb.fillPolygon(pc.problem.V{idsol}, colors(idx, :), 'FaceAlpha', 0.3);
%     set(get(get(hFill,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
% 
%     hBoundary = mb.drawPolygon(pc.problem.V{idsol}, 'color', colors(idx, :));
%     set(get(get(hBoundary,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
% end
% hPt = drawPoint(pc.problem.S(1:2, solution_ids)', 'color', 'k', 'marker', 'o', 'markersize', 15, 'markerfacecolor',  'k', 'markeredgecolor', 'w');
%     set(get(get(hPt,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
% 
% for idx = 1:numel(solution_ids)
%     idsol = solution_ids(idx);
%     sensor_middle_angle = pc.problem.S(3,idsol)+pc.sensors.angle/2;
%     line = [pc.problem.S(1:2, idsol)', cos(sensor_middle_angle), sin(sensor_middle_angle)];
%     edge = createEdge(line, 200);
%     
%     drawEdge(edge, 'color', colors(idx, :), 'lineWidth', 5 );%, 'marker', 'p', 'markersize', 5, 'markerfacecolor',  colors(idx, :));
% end

% drawPoint(pc.problem.W');
scatter(pc.problem.W(1,:)', pc.problem.W(2,:)', 15, solution.ax);
axis equal
