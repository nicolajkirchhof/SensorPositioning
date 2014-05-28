function draw_visibility_matrix(pc)
%% draws all sensor fovs that are on polygon edges and colors the workspace points according to the
% number of sensor they are seen by

%% find edge positions in sensorposes

[~, id_in_ring] = ismember( pc.problem.S(1:2,:)', pc.environment.walls.ring', 'rows');
point_ids = unique(id_in_ring);
point_ids = point_ids(point_ids>0);
num_points = numel(point_ids);

colors = hsv(num_points);
colors_perm = colors(randperm(num_points), :);

cla; hold on;
draw_environment(pc);

for idpt = 1:num_points
    idpoint = point_ids(idpt);
    selected_polys = id_in_ring==idpoint;
    merged_poly = bpolyclip_batch(pc.problem.V(selected_polys), 3, 1:sum(selected_polys), pc.common.bpolyclip_batch_options);
    mb.drawPolygon(merged_poly{1}, 'color', colors_perm(idpt, :));
    mb.drawPoint(pc.environment.walls.ring(:,idpoint), 'marker', 'p', 'color', colors_perm(idpt, :), 'markersize', 10);  
end 

%% calculate the number of sensors that every workspace point is seen by
num_seen_by = sum(pc.problem.xt_ij, 1);
scatter(pc.problem.W(1,:)', pc.problem.W(2,:)', 5, num_seen_by');
colorbar;
%%
% fun_legend_off =@(h) set(get(get(h,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
% h = cellfun(@(x)mb.fillPolygon(x, [0 1 1], 'FaceAlpha', alpha) , pc.sensorspace.extra.vis_polys);
% %%
% legend(h(1), sprintf('Visible * %g', alpha));
% arrayfun(fun_legend_off, h(2:end));
% 
% legend off
% legend show