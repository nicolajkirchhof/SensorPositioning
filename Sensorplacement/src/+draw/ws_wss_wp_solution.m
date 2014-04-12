function wss_wp_solution(pc, sol)

sensor_ids = find(sol.x(1:pc.problem.num_sensors));
comb_ids = find(sol.x(pc.problem.num_sensors+1:pc.problem.num_comb));
ws_qual = sol.x(pc.problem.num_sensors+(1:pc.problem.num_positions));
figure('Name', pc.name);
% subplot(1
colors =  hsv(numel(sensor_ids));
color_ids = randperm(numel(sensor_ids));
colors = colors(color_ids, :);
cla;
title(sprintf('Solution with %d choosen Sensors', sum(sol.x(1:pc.problem.num_sensors))));
% draw.workspace(pc);
draw.environment(pc);
hold on;
for idx = 1:numel(sensor_ids)
    idsol = sensor_ids(idx);
%     disp(polyarea(pc.problem.V{1,idsol}.x, pc.problem.V{1,idsol}.y));
%     hFill = mb.fillPolygon(pc.problem.V{idsol}, colors(idx, :), 'FaceAlpha', 0.3);
%     set(get(get(hFill,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend

    hBoundary = mb.drawPolygon(pc.problem.V{idsol}, 'color', colors(idx, :));
    legend(hBoundary, sprintf('Sensor %d ', idsol));
%     set(get(get(hBoundary,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
end
% hPt = drawPoint(pc.problem.S(1:2, sensor_ids)', 'color', 'k', 'marker', 'o', 'markersize', 15, 'markerfacecolor',  'k', 'markeredgecolor', 'w');
%     set(get(get(hPt,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend

for idx = 1:numel(sensor_ids)
    idsol = sensor_ids(idx);
    sensor_middle_angle = pc.problem.S(3,idsol)+pc.sensors.angle/2;
    line = [pc.problem.S(1:2, idsol)', cos(sensor_middle_angle), sin(sensor_middle_angle)];
    edge = createEdge(line, 200);
    
    drawEdge(edge, 'color', colors(idx, :), 'lineWidth', 5 );%, 'marker', 'p', 'markersize', 5, 'markerfacecolor',  colors(idx, :));
end

% drawPoint(pc.problem.W');
scatter(pc.problem.W(1,:)', pc.problem.W(2,:), [], ws_qual);
colorbar 
legend off;
legend on;
