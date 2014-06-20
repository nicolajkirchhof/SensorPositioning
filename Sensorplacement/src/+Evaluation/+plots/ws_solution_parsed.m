function ws_solution_parsed(solution)
%%
sol = solution.solution;
discretization = solution.discretization;
% sol_ids = find(sol.x(1:discretization.num_sensors));
    solnames = sol.variables.name(sol.variables.value(1:numel(sol.variables.name))==1);
    solstr = cellfun(@(str) sscanf(str, 's%d'), solnames, 'uniformoutput', false);
    solstr = solstr(~cellfun(@isempty, solstr));
    sol_ids = unique(cell2mat(solstr'));
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
% colors =  hsv(numel(sol_ids));
colors =  repmat(linspace(0.5, 0.5, numel(sol_ids)), 3, 1)';
% color_ids = randperm(numel(sol_ids));
% colors = colors(color_ids, :);
%%
cla;
title(sprintf('Solution with %d choosen Sensors', numel(sol_ids)));
% draw.workspace(pc);
Environment.draw(solution.environment);
% draw.environment(discretization);
hold on;
% for idx = 1:numel(sol_ids)
%     idsol = sol_ids(idx);
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
    hBoundary = mb.drawPolygon(discretization.vfovs(sol_ids), 'color', [0.2 0.2 0.2]);
%     hBoundary = hBoundary(1);
%     set(get(get(hBoundary,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
%%
hPt = drawPoint(discretization.sp(1:2, sol_ids)', 'color', [0.7 0.7 0.7], 'marker', 'o', 'markersize', 10, 'markerfacecolor',  [0.2 0.2 0.2], 'markeredgecolor', 'w');
    set(get(get(hPt,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
for idx = 1:numel(sol_ids)
    idsol = sol_ids(idx);
    sensor_middle_angle = discretization.sp(3,idsol)+deg2rad(solution.config.discretization.sensor.fov/2);
    line = [discretization.sp(1:2, idsol)', cos(sensor_middle_angle), sin(sensor_middle_angle)];
    edge = createEdge(line, 500);
    
    drawEdge(edge, 'color', colors(idx, :), 'lineWidth', 2 );%, 'marker', 'p', 'markersize', 5, 'markerfacecolor',  colors(idx, :));
end
%%
if sum(ws_qual) == discretization.num_positions
    scatter(discretization.wpn(1,:)', discretization.wpn(2,:), 5, ws_qual(wp_qual_flt)*1e6, 'filled');
    colormap gray
else
 drawPoint(discretization.wpn');
end
% colorbar;
