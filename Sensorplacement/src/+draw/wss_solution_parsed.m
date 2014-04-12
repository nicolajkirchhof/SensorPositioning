function wss_solution_parsed(pc, sol)
%%
% sol.sensor.ids = find(sol.x(1:pc.problem.num_sensors));
ucomb = comb2unique(sort(sol.sensor.ids));
ucomb_flt = pc.problem.sc_idx(:,1)==ucomb(1,1)&pc.problem.sc_idx(:,2)==ucomb(1,2);
for ic = 2:size(ucomb,1)
    ucomb_flt = ucomb_flt | (pc.problem.sc_idx(:,1)==ucomb(ic,1)&pc.problem.sc_idx(:,2)==ucomb(ic,2));
end
    
%%
ws_qual 
if ~isempty(ws_qual) && numel(ws_qual)>pc.problem.num_positions
wp_cov_qual_flt = strfind(sol.linearConstraints.name, '_coverage');
wp_comb_qual_flt = strfind(sol.linearConstraints.name, '_comb');
wp_comb_qual_flt = ~cellfun(@isempty, wp_comb_qual_flt);
wp_cov_qual_flt = ~cellfun(@isempty, wp_cov_qual_flt);

if any(wp_comb_qual_flt)
    wp_qual_flt = wp_comb_qual_flt;
else
    wp_qual_flt = wp_cov_qual_flt;
end
else 
    wp_qual_flt = true(size(ws_qual));
end
%%
% colors =  hsv(numel(sol.sensor.ids));
colors =  repmat(linspace(0.5, 0.5, numel(sol.sensor.ids)), 3, 1)';
% color_ids = randperm(numel(sol.sensor.ids));
% colors = colors(color_ids, :);
%%
cla;
title(sprintf('Solution with %d choosen Sensors', numel(sol.sensor.ids)));
% draw.workspace(pc);
draw.environment(pc);
hold on;
% for idx = 1:numel(sol.sensor.ids)
%     idsol = sol.sensor.ids(idx);
%     disp(polyarea(pc.problem.V{1,idsol}.x, pc.problem.V{1,idsol}.y));
%     hFill = mb.fillPolygon(pc.problem.V{idsol}, colors(idx, :), 'FaceAlpha', 0.3);
%     set(get(get(hFill,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend

%     hBoundary = mb.drawPolygon(pc.problem.V{idsol}, 'color', colors(idx, :));
%     hBoundary = hBoundary(1);
%     set(get(get(hBoundary,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
% end
%%
    hBoundary = mb.drawPolygon(pc.problem.V(sol.sensor.ids), 'color', [0.2 0.2 0.2]);
%     hBoundary = hBoundary(1);
%     set(get(get(hBoundary,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
%%
hPt = drawPoint(pc.problem.S(1:2, sol.sensor.ids)', 'color', [0.7 0.7 0.7], 'marker', 'o', 'markersize', 10, 'markerfacecolor',  [0.2 0.2 0.2], 'markeredgecolor', 'w');
    set(get(get(hPt,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
for idx = 1:numel(sol.sensor.ids)
    idsol = sol.sensor.ids(idx);
    sensor_middle_angle = pc.problem.S(3,idsol)+pc.sensors.angle/2;
    line = [pc.problem.S(1:2, idsol)', cos(sensor_middle_angle), sin(sensor_middle_angle)];
    edge = createEdge(line, 200);
    
    drawEdge(edge, 'color', colors(idx, :), 'lineWidth', 2 );%, 'marker', 'p', 'markersize', 5, 'markerfacecolor',  colors(idx, :));
end
%%
if ~isempty(ws_qual)
    scatter(pc.problem.W(1,:)', pc.problem.W(2,:), 5, ws_qual(wp_qual_flt)*1e6, 'filled');
    colormap gray
else
 drawPoint(pc.problem.W');
end
% colorbar;
