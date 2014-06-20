function wss_wp_solution(discretization, sol, name)

if nargin < 3
    name = 'noname';
end
%%
sensor_ids = find(sol.x(1:discretization.num_sensors));
comb_ids = find(sol.x(discretization.num_sensors+1:discretization.num_comb));
ws_qual = sol.x(discretization.num_sensors+(1:discretization.num_positions));
figure('Name', name);
% subplot(1
colors =  hsv(numel(sensor_ids));
color_ids = randperm(numel(sensor_ids));
colors = colors(color_ids, :);
cla;
title(sprintf('Solution with %d choosen Sensors', sum(sol.x(1:discretization.num_sensors))));
% draw.workspace(pc);
%%
draw.environment(discretization);
hold on;
for idx = 1:numel(sensor_ids)
    idsol = sensor_ids(idx);
%     disp(polyarea(discretization.V{1,idsol}.x, discretization.V{1,idsol}.y));
%     hFill = mb.fillPolygon(discretization.V{idsol}, colors(idx, :), 'FaceAlpha', 0.3);
%     set(get(get(hFill,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend

    hBoundary = mb.drawPolygon(discretization.V{idsol}, 'color', colors(idx, :));
    legend(hBoundary, sprintf('Sensor %d ', idsol));
%     set(get(get(hBoundary,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
end
% hPt = drawPoint(discretization.S(1:2, sensor_ids)', 'color', 'k', 'marker', 'o', 'markersize', 15, 'markerfacecolor',  'k', 'markeredgecolor', 'w');
%     set(get(get(hPt,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend

for idx = 1:numel(sensor_ids)
    idsol = sensor_ids(idx);
    sensor_middle_angle = discretization.S(3,idsol)+discretization.sensors.angle/2;
    line = [discretization.S(1:2, idsol)', cos(sensor_middle_angle), sin(sensor_middle_angle)];
    edge = createEdge(line, 200);
    
    drawEdge(edge, 'color', colors(idx, :), 'lineWidth', 5 );%, 'marker', 'p', 'markersize', 5, 'markerfacecolor',  colors(idx, :));
end

% drawPoint(discretization.W');
scatter(discretization.W(1,:)', discretization.W(2,:), [], ws_qual);
colorbar 
legend off;
legend on;
