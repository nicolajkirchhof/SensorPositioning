function pc = area_diameter_constraint(pc)

%% TBD to calculate area and diameter constraint can be determined from xt_ij 
% max_diameter = pc.sensors.distance;
aoa_error_annulus_poly = mb.createAnnulusSegment(0,0, pc.sensors.distance.min, pc.sensors.distance.max, 0, pc.sensors.aoa_error, pc.common.polyline_verticies);
sensor_circle = mb.createAnnulusSegment(0,0, pc.sensors.distance.min, pc.sensors.distance.max, 0, pc.sensors.fov, pc.common.polyline_verticies);
% sensor_circle = [0 0; circleArcToPolyline([0 0 pc.sensors.distance 0 pc.sensors.fov], pc.common.polyline_verticies)];
max_boundingbox_rect = boxToRect(boundingBox(sensor_circle));
max_boundingbox_area = max_boundingbox_rect(3)*max_boundingbox_rect(4);
max_area  = pc.sensors.distance.max^2*pi*(pc.sensors.fov/360);
%%
%build all unique two sensor combinations polys and calculate their size
%and diameter
%unique_combinations
% jobs = mat2cell(unique_combinations, ones(num_unique_combinations,1), 2);
xing_polys = bpolyclip_batch(pc.problem.V, 1, unique_combinations, true, 1, 1, 10);
xing_rings = mb.flattenPolygon(xing_polys);
clearvars xing_polys;
xing_areas = cellfun(@mb.polygonArea, xing_rings);
%%
% get all workspace points that are in the different xings
% slow approach
% in_xing_poly = arrayfun(@(c1, c2) pc.problem.xt_ij(c1, :)&pc.problem.xt_ij(c2, :), unique_combinations(:,1), unique_combinations(:,2), 'uniformoutput', false);
pts = int64(pc.problem.W(1:2,:));
in_xing_ring = cell2mat(cellfun(@(ring) binpolygon(pts, ring, pc.common.grid_limit), xing_rings, 'uniformoutput', false)');
% 

%% for each column (workspace pos) create quality constraints
quality_row_ids = cell(m, 1);
quality_colum_ids_diag = cell(m, 1);
quality_colum_ids_qwx = cell(m, 1);
quality_values_diag_boundingbox = cell(m, 1);
quality_values_diag_area = cell(m, 1);
quality_values_qwx = cell(m, 1);
fun_rect_area = @(rect) rect(3)*rect(4);
row_idx = 0;
pct = 0;
tic;
for idwp = 1:m
      sensorcomb_ids = in_xing_ring(:, idwp);
      num_constraints = sum(sensorcomb_ids);
      quality_colum_ids_diag{idwp} = find(sensorcomb_ids);
      quality_colum_ids_qwx{idwp} = repmat(idwp, num_constraints, 1);
      quality_row_ids{idwp} = row_idx+(1:num_constraints)';
      row_idx = row_idx+num_constraints;
      quality_values_diag_area{idwp} = (-1 + xing_areas(sensorcomb_ids)/max_area)';
      sensorcomb_qualities_boundingbox = cellfun(@(ply) fun_rect_area(boundingBox(ply)), xing_rings(sensorcomb_ids));
      quality_values_diag_boundingbox{idwp} = (-1 + sensorcomb_qualities_boundingbox/max_boundingbox_area)';
      quality_values_qwx{idwp} = ones(num_constraints, 1);

    if pct < floor(idwp*10/m)
        pct = floor(idwp*10/m);
        rest_time = toc/pct*(10-pct);
        fprintf(1, '%d pct %g sec to go\n', pct*10, rest_time);
    end
end
%%%
% sensor_syms = sym('s', [pc.problem.num_sensors 1]);
quality_colum_ids = [cell2mat(quality_colum_ids_diag); cell2mat(quality_colum_ids_qwx)];
quality_row_ids = repmat(cell2mat(quality_row_ids), 2, 1);
quality_values_boundingbox = [cell2mat(quality_values_diag_boundingbox); cell2mat(quality_values_qwx)];
quality_values_area = [cell2mat(quality_values_diag_area); cell2mat(quality_values_qwx)];

%%
num_quality_const = numel(quality_values_area);
pc.model.quality_area.obj_quality = ones(num_quality_const,1);
pc.model.quality_area.A_quality_area = sparse(quality_row_ids, quality_colum_ids, quality_values_area, num_quality_const, num_quality_const);
pc.model.quality_area.A_quality_boundingbox = sparse(quality_row_ids, quality_colum_ids, quality_values_boundingbox, num_quality_const, num_quality_const);
pc.model.quality_area.rhs_quality = inf(num_quality_const, 1);
pc.model.quality_area.lhs_quality = sparse(num_quality_const, 1);
clearvars quality* xing*
