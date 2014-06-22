function wss_solution_parsed(solution)
%%
% sol.sensor.ids = find(sol.x(1:discretization.num_sensors));
discretization = solution.discretization;
sol = solution.solution;

ucomb = comb2unique(sort(sol.sensor.ids));
ucomb_flt = discretization.sc(:,1)==ucomb(1,1)&discretization.sc(:,2)==ucomb(1,2);
for ic = 2:size(ucomb,1)
    ucomb_flt = ucomb_flt | (discretization.sc(:,1)==ucomb(ic,1)&discretization.sc(:,2)==ucomb(ic,2));
end
    
%%
ws_qual = sol.ax;
if ~isempty(ws_qual) && numel(ws_qual)>discretization.num_positions
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
Environment.draw(solution.environment);
% draw.environment(pc);
hold on;
% for idx = 1:numel(sol.sensor.ids)
%     idsol = sol.sensor.ids(idx);
%     disp(polyarea(discretization.V{1,idsol}.x, discretization.V{1,idsol}.y));
%     hFill = mb.fillPolygon(discretization.V{idsol}, colors(idx, :), 'FaceAlpha', 0.3);
%     set(get(get(hFill,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend

%     hBoundary = mb.drawPolygon(discretization.V{idsol}, 'color', colors(idx, :));
%     hBoundary = hBoundary(1);
%     set(get(get(hBoundary,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
% end
%%
    hBoundary = mb.drawPolygon(discretization.vfovs(sol.sensor.ids), 'color', [0.2 0.2 0.2]);
%     hBoundary = hBoundary(1);
%     set(get(get(hBoundary,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
%%
hPt = drawPoint(discretization.sp(1:2, sol.sensor.ids)', 'color', [0.7 0.7 0.7], 'marker', 'o', 'markersize', 10, 'markerfacecolor',  [0.2 0.2 0.2], 'markeredgecolor', 'w');
    set(get(get(hPt,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
for idx = 1:numel(sol.sensor.ids)
    idsol = sol.sensor.ids(idx);
    sensor_middle_angle = discretization.sp(3,idsol)+deg2rad(solution.config.discretization.sensor.fov/2);
    line = [discretization.sp(1:2, idsol)', cos(sensor_middle_angle), sin(sensor_middle_angle)];
    edge = createEdge(line, 500);
    
    drawEdge(edge, 'color', colors(idx, :), 'lineWidth', 2 );%, 'marker', 'p', 'markersize', 5, 'markerfacecolor',  colors(idx, :));
end
%%
if ~isempty(ws_qual)
    scatter(discretization.wpn(1,:)', discretization.wpn(2,:), 5, ws_qual(wp_qual_flt)*1e6, 'filled');
    colormap gray
else
 drawPoint(discretization.wpn');
end
% colorbar;
