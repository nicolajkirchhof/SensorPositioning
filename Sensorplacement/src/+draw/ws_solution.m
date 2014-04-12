function ws_solution(pc, sol)
%%
% sol_ids = find(sol.x(1:pc.problem.num_sensors));
    solnames = sol.variables.names(sol.x>0);
    sol_ids = unique(cell2mat(cellfun(@(str) sscanf(str, 's%d'), solnames, 'uniformoutput', false)));

ws_qual = sol.ax;

if ~isempty(ws_qual) && numel(ws_qual)>pc.problem.num_positions
wp_cov_qual_flt = strfind(sol.linearConst.names, '_coverage');
wp_comb_qual_flt = strfind(sol.linearConst.names, '_comb');
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

% colors =  hsv(numel(sol_ids));
% colors =  repmat(linspace(0, 1, numel(sol_ids)), 3, 1)';
colors =  repmat(linspace(0, 0, numel(sol_ids)), 3, 1)';
color_ids = randperm(numel(sol_ids));
colors = colors(color_ids, :);
cla;
title(sprintf('Solution with %d choosen Sensors', numel(sol_ids)));
% draw.workspace(pc);
draw.environment(pc);
hold on;
for idx = 1:numel(sol_ids)
    idsol = sol_ids(idx);
%     disp(polyarea(pc.problem.V{1,idsol}.x, pc.problem.V{1,idsol}.y));
%     hFill = mb.fillPolygon(pc.problem.V{idsol}, colors(idx, :), 'FaceAlpha', 0.3);
%     set(get(get(hFill,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend

    hBoundary = mb.drawPolygon(pc.problem.V{idsol}, 'color', colors(idx, :));
    set(get(get(hBoundary,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
end
hPt = drawPoint(pc.problem.S(1:2, sol_ids)', 'color', 'k', 'marker', 'o', 'markersize', 15, 'markerfacecolor',  'k', 'markeredgecolor', 'w');
    set(get(get(hPt,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend

for idx = 1:numel(sol_ids)
    idsol = sol_ids(idx);
    sensor_middle_angle = pc.problem.S(3,idsol)+pc.sensors.angle/2;
    line = [pc.problem.S(1:2, idsol)', cos(sensor_middle_angle), sin(sensor_middle_angle)];
    edge = createEdge(line, 200);
    
    drawEdge(edge, 'color', colors(idx, :), 'lineWidth', 5 );%, 'marker', 'p', 'markersize', 5, 'markerfacecolor',  colors(idx, :));
end

if ~isempty(ws_qual)
    scatter(pc.problem.W(1,:)', pc.problem.W(2,:), [], ws_qual(wp_qual_flt), 'filled');
else
 drawPoint(pc.problem.W');
end
colorbar;
