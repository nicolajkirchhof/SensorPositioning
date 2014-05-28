function draw_sensor_point_correspondences(pc)

switch pc.workspace.sampling_technique
    case pc.common.sampling_techniques.random
        circ_r = pc.workspace.min_position_distance/2;
    case {pc.common.sampling_techniques.grid, pc.common.sampling_techniques.uniform}
        circ_r = pc.workspace.grid_position_distance/2;
    otherwise
        error('not implemented');
end 
%% 
cla
draw_environment(pc);
%
hold on;
for idw = 1:pc.workspace.number_of_positions
    sensors_num = sum(pc.problem.Solution.xt_ij_selected(:,idw));
    sensors_idx = find(pc.problem.Solution.xt_ij_selected(:,idw));
    circ_angles_deg = 360/sensors_num;
    for idc = 1:sensors_num
        pl = int64(circleArcToPolyline([double(pc.problem.W(1:2, idw)') circ_r  circ_angles_deg*(idc-1) circ_angles_deg], 10));
        poly = [pl; pc.problem.W(1:2, idw)'];
        fillPolygon(poly, pc.problem.Solution.sensor_colors(sensors_idx(idc),:));
    end
end

for idx = 1:pc.problem.Solution.sensor_num
    idsol = pc.problem.Solution.sensor_ids(idx);
%     disp(polyarea(pc.problem.V{1,idsol}.x, pc.problem.V{1,idsol}.y));
    %fillPolygon(pc.problem.V{idsol}.x, pc.problem.V{idsol}.y, pc.problem.Solution.sensor_colors(idx, :), 'FaceAlpha', 0.3);
    mb.drawPolygon(pc.problem.V{idsol}, 'color', pc.problem.Solution.sensor_colors(idx, :), 'linewidth', 2);
%     drawPolygon(pc.problem.V{idsol}.x, pc.problem.V{idsol}.y, 'color', 'k');
    drawPoint(pc.problem.S(1:2, idsol)', 'color', pc.problem.Solution.sensor_colors(idx, :), 'marker', '*' );
    ray = createRay(pc.problem.S(1:2, idsol)', pc.problem.S(3,idsol)');
    ray(:,3:4) = bsxfun(@plus, ray(:,1:2), ray(:,3:4)*0.5);
    drawEdge(ray, 'color', 'w');
end


% plot_workspace(pc)