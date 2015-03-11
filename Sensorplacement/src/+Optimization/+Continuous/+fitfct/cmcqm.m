function [ qval, ply_remaining ] = cmcqm( x  )
%cmqcm The first call of this function does the initialization, thus it has to
% contain an initialization struct x containing:
% .ply = the combined polygon
% .ply_to_cover = the combined polygon without occupied
% .contours = the contours lookup
% .placeable_edges = all edges where sensors can be placed

persistent bpolyclip_options bpolyclip_batch_options is_initialized default_annulus ...
    fun_sensorfov fun_transform area_to_cover ply ply_to_cover contours placeable_edges ...
    placeable_edgelenghts_scale placeable_edgelenghts_lut placeable_edges_dir

if isempty(is_initialized)
    ply = x.ply;
    ply_to_cover = x.ply_to_cover;
    contours = x.contours;
    placeable_edges = x.placeable_edges;
    
    bpolyclip_options = Configurations.Bpolyclip.vfov;
    bpolyclip_batch_options = Configurations.Bpolyclip.combine(bpolyclip_options, true);
    
    default_annulus = [0 10000 9928 9715 9362 8876 8262 7531 6691 0;
        0 0 1194 2371 3514 4606 5633 6579 7431 0 ];
    fun_sensorfov = @(x,y,theta) int64(bsxfun(@plus, ([cos(theta) -sin(theta); sin(theta)  cos(theta)]*default_annulus), [x;y]));
    
    fun_transform = @(ply,sp) int64(bsxfun(@plus, [sp(1);sp(2)], [cos(sp(3)) -sin(sp(3)); sin(sp(3))  cos(sp(3))]*double(ply)));
    % config = Configurations.Discretization.iterative;
    area_to_cover = mb.polygonArea(ply_to_cover);
    
    %%
    placeable_edgelenghts_scale = x.placeable_edgelenghts_scale;
    placeable_edgelenghts_lut = x.placeable_edgelenghts_lut;
    placeable_edges_dir = x.placeable_edges_dir;
    
    % phi = x.phi;
    x = [x.x x.phi];
    %%
    is_initialized = true;
end

id_mid = numel(x)/2;
phi = x(id_mid+1:end);
x = x(1:id_mid);
phi = phi(:);
x = x(:);

ids_before = arrayfun(@(x) sum(placeable_edgelenghts_lut(1:end-1)<=x), x);
dist_to_first = (x-placeable_edgelenghts_lut(ids_before))*placeable_edgelenghts_scale;
gsp = placeable_edges(ids_before, 1:2) + bsxfun(@times, placeable_edges_dir(ids_before,:), dist_to_first);
sp = double([gsp'; phi(:)'*(2*pi)]);

%%
vis_polys = visilibity(sp(1:2, :), ply, 1, 0, false);
vis_polys = cellfun(@(p) int64(ceil(p)), vis_polys, 'uniformoutput', false);

%%%
% calculates the sensor fov, the inner ring is defined by the min distance and the outer ring by
% the max distance. Since both rings have the same orientation, the inner is flipped to get a
% polygon
% default_annulus = mb.createAnnulusSegment(0,0,config.sensor.distance(1), config.sensor.distance(2), 0, config.sensor.fov, config.sensorspace.ringvertices);
sensor_fovs = arrayfun(fun_sensorfov, sp(1,:), sp(2,:), sp(3,:), 'uniformoutput', false);
[sensor_visibility_polygons, area_svp] = cellfun(@(p1, p2) bclipper(p1, p2, 1), vis_polys, sensor_fovs, 'uniformoutput', false);
flt_svp = ~cellfun(@isempty, sensor_visibility_polygons) & ~cellfun(@(a) a< 10000, area_svp);

sp = sp(:, flt_svp);
sensor_visibility_polygons = sensor_visibility_polygons(flt_svp);

comb_ids = comb2unique(1:sum(flt_svp));
if isempty(comb_ids)
    qval = 1;
    return
end
%%
% calculate distances, move contours to positions and mirror them on the direct connection
distances = sqrt(sum((sp(1:2, comb_ids(:,1))-sp(1:2, comb_ids(:,2))).^2, 1));
flt_zero = distances>50;

comb_ids = comb_ids(flt_zero, :);
distances = distances(flt_zero);

flt_max = distances<13100;

comb_ids = comb_ids(flt_max, :);
distances = distances(flt_max);

if isempty(comb_ids)
    qval = 1;
    return
end

contour_ids = round(distances/100);
%%%
% calculate angle between sp and place contours
sc_angles = mb.angle2PointsFast(sp(1:2, comb_ids(:,1)),sp(1:2, comb_ids(:,2)));
contour_plys = contours.b_chulls(contour_ids);

% contour_plys_chng = arrayfun(@(p,x,y, ang) {fun_transform(p{1}{1}, x, y,ang), fun_transform(p{1}{2}, x, y,ang)},...
%     contour_plys(:), sp(1, comb_ids(:,1))', sp(2, comb_ids(:,1))',  sc_angles(:), 'uniformoutput', false);

%%
% poly_combine_jobs = [comb_ids, num_vfovs+comb_contour_ids(:,1); comb_ids, num_vfovs+comb_contour_ids(:,2)];
num_jobs = size(comb_ids, 1);
bvfov_qval_intersections = cell(num_jobs, 1);
bvfov_qval_areas = zeros(num_jobs, 1);
cnt = 1;
%%
for idj = 1:num_jobs
    %%
   btmp = bclipper(sensor_visibility_polygons{comb_ids(idj, 1)}, sensor_visibility_polygons{comb_ids(idj, 2)}, 1);
   if ~isempty(btmp)    
    contour_plys_sc = {fun_transform(contour_plys{idj}{1}, sp(:, comb_ids(idj,1))), fun_transform(contour_plys{idj}{2}, sp(:, comb_ids(idj,1)))};
    [btmp, barea] = bclipper(btmp, contour_plys_sc, 1);
    if ~isempty(btmp) && barea > 10000
        bvfov_qval_intersections{cnt} = btmp;
        bvfov_qval_areas(cnt) = barea;
        cnt = cnt + 1;
   end
   end
end
%%
bvfov_qval_intersections = [bvfov_qval_intersections{1:cnt-1}];
bvfov_qval_areas = bvfov_qval_areas(1:cnt-1);
%%
ptmp = ply_to_cover;
idi = 1;

while idi <= numel(bvfov_qval_intersections) && ~isempty(ptmp)
        [ptmp, area_remaining] = bclipper(ptmp, bvfov_qval_intersections(idi), 0);
        idi = idi+1;
end

%%
qval = area_remaining/area_to_cover - 0.01; % 0.01 is the allowed error of 1%

return;
%%
for idp = 1:numel(vfov_qval_polys)
    bpolyclip(vfov_qval_polys{idp}, vfov_qval_polys{idp}, 1);
end
%%
ptmp = bvfov_qval_intersections{1};
idi = 2;
while idi <= numel(bvfov_qval_intersections)
    %     try
    covered_ply = bpolyclip(ptmp, bvfov_qval_intersections{idi}, 3);
    idi = idi+1;
    %     catch
    %         covered_ply = cellfun(@(p) mb.mergePoints(p, 10), ptmp, 'uniformoutput', false);
    %     pause;
    %     end
end
%%
ptmp = bvfov_qval_intersections{1};
for idi = 2:numel(bvfov_qval_intersections)
    ptmp = bpolyclip(ptmp, bvfov_qval_intersections{idi}, 3);
    %     part_cut{idi} = bpolyclip_batch(bvfov_qval_intersections, 3, 1:idi);
end
%%
cla;
% Environment.draw(input.environment, false);
% mb.drawPolygon(sensor_visibility_polygons);
for idi = 1:numel(part_cut)
    if ~isempty(part_cut{idi})
        h = mb.drawPolygon(part_cut{idi}, 'color', 'g');
        disp(idi);
        pause;
        delete(h);
    end
end
%%
cla;
Environment.draw(input.environment, false);
mb.drawPolygon(sensor_visibility_polygons);
for idi = 1:numel(vfov_int_ply)
    h = mb.drawPolygon(vfov_int_ply{idi}, 'color', 'g');
    disp(idi);
    pause;
    delete(h);
end
%%
cla;
Environment.draw(input.environment, false);
mb.drawPolygon(sensor_visibility_polygons);

for idj = 1:numel(poly_combine_jobs)
    h = mb.drawPolygon(vfov_qval_polys(poly_combine_jobs{idj}(1)), 'color', 'g');
    h3 = mb.drawPolygon(vfov_qval_polys(poly_combine_jobs{idj}(2)), 'color', 'y');
    h2 = mb.drawPolygon(vfov_qval_polys(poly_combine_jobs{idj}(3)), 'color', 'r');
    h1 = mb.drawPolygon(bvfov_qval_intersections{idj}, 'color', 'm');
    disp(idj);
    xlim([-1000 5000]);
    ylim([0 10000]);
    pause;
    delete([h(:); h1(:); h2(:); h3(:)]);
end
%%
cla;
Environment.draw(input.environment, false);
mb.drawPolygon(sensor_visibility_polygons);
for idp = 1:numel(bvfov_qval_intersections)
    h = mb.drawPolygon(bvfov_qval_intersections{idp}, 'color', 'g');
    disp(idp);
    pause;
end
%%
cla;
Environment.draw(input.environment, false);
mb.drawPolygon(sensor_visibility_polygons);
for idc = 1:numel(contour_plys_chng)
    h = mb.drawPolygon(contour_plys_chng{idc}, 'color', 'g');
    disp(idc);pause;
    delete(h);
end

%%
% name = 'conference_room';
name = 'large_flat';
load(sprintf('tmp/%s/gco.mat', name));
%%
clearvars -except gco name;
clear cmcqm
%%
sol = gco{10, 10};
input = Experiments.Diss.(name)(sol.num_sp, sol.num_wpn);
opt = Optimization.Continuous.prepare_opt(input, sol.discretization.sp);

Optimization.Continuous.fitfct.cmcqm(opt)
%%%
x = opt.x+0.01;
phi = opt.phi+0.1;
Optimization.Continuous.fitfct.cmcqm([x phi])

%% TODO:
% Assign to edge where edge_id ist first vertex
% calculate distance to first vertex to get dist on line
% use opt + dist_on_line/edgelength_scale to calculate x



%%
[qval, ply_remaining] = Optimization.Continuous.cmqcm(sp, ply, ply_to_cover, contours);
mb.drawPolygon(ply_remaining, 'color', 'g');

