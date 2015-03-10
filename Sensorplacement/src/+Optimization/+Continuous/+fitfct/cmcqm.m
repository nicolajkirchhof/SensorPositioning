function [ qval, ply_remaining ] = cmcqm( x  )
%cmqcm The first call of this function does the initialization, thus it has to
% contain an initialization struct x containing:
% .ply = the combined polygon
% .ply_to_cover = the combined polygon without occupied
% .contours = the contours lookup
% .placeable_edges = all edges where sensors can be placed

persistent bpolyclip_options bpolyclip_batch_options is_initialized default_annulus ...
    fun_sensorfov fun_transform area_to_cover ply ply_to_cover contours placeable_edges ...
    placeable_edgelenghts_scale placeable_edgelenghts_lut placeable_edges_dir ply_to_cover_dbl

if isempty(is_initialized)
    ply = x.ply;
    ply_to_cover = x.ply_to_cover;
    ply_to_cover_dbl = cellfun(@double, ply_to_cover{1}, 'uniformoutput', false);
    contours = x.contours;
    placeable_edges = x.placeable_edges;
    
    bpolyclip_options = Configurations.Bpolyclip.vfov;
    bpolyclip_batch_options = Configurations.Bpolyclip.combine(bpolyclip_options, true);
    
    default_annulus = [0 10000 9928 9715 9362 8876 8262 7531 6691 0;
        0 0 1194 2371 3514 4606 5633 6579 7431 0 ];
    fun_sensorfov = @(x,y,theta) int64(bsxfun(@plus, ([cos(theta) -sin(theta); sin(theta)  cos(theta)]*default_annulus), [x;y]));
    
    fun_transform = @(ply,x,y, theta) int64(bsxfun(@plus, [x;y], [cos(theta) -sin(theta); sin(theta)  cos(theta)]*double(ply)));
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
sp = [gsp'; phi(:)'*(2*pi)];

%%
vis_polys = visilibity(sp(1:2, :), ply, 1, 100, 0);
jobs_vispolys = repmat((1:numel(vis_polys))', 1, 2);
vis_polys = bpolyclip_batch(vis_polys, 1, jobs_vispolys, 1, 100, 10);
vis_polys = cellfun(@(p) int64(ceil(p{1}{1})), vis_polys, 'uniformoutput', false);

%%%
% calculates the sensor fov, the inner ring is defined by the min distance and the outer ring by
% the max distance. Since both rings have the same orientation, the inner is flipped to get a
% polygon
% default_annulus = mb.createAnnulusSegment(0,0,config.sensor.distance(1), config.sensor.distance(2), 0, config.sensor.fov, config.sensorspace.ringvertices);
sensor_fovs = arrayfun(fun_sensorfov, sp(1,:), sp(2,:), sp(3,:), 'uniformoutput', false);
[sensor_visibility_polygons] = cellfun(@(p1, p2) bpolyclip(p1, p2), vis_polys, sensor_fovs, 'uniformoutput', false);
flt_svp = ~cellfun(@isempty, sensor_visibility_polygons);

comb_ids = comb2unique(find(flt_svp));
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
% middle_pt = sp(1:2, comb_ids_flt(:,1))+0.5*(-sp(1:2, comb_ids_flt(:,1))+sp(1:2, comb_ids_flt(:,2)));
contour_plys = contours.b_chulls(contour_ids);

contour_plys_chng = arrayfun(@(p,x,y, ang) {fun_transform(p{1}{1}, x, y,ang), fun_transform(p{1}{2}, x, y,ang)},...
    contour_plys(:), sp(1, comb_ids(:,1))', sp(2, comb_ids(:,1))',  sc_angles(:), 'uniformoutput', false);

% [bvfov_qval_intersections_A] = cellfun(@(p1, p2) bpolyclip(p1, p2{1}), sensor_visibility_polygons, contour_plys_chng, 'uniformoutput', false);
% [bvfov_qval_intersections_B] = cellfun(@(p1, p2) bpolyclip(p1, p2{2}), sensor_visibility_polygons, contour_plys_chng, 'uniformoutput', false);
% bvfov_qval_intersections = [mb.flattenPolygon(bvfov_qval_intersections_A), mb.flattenPolygon(bvfov_qval_intersections_B)];
%%
if ~all(flt_svp)
    sp_ids = find(flt_svp);
    for idv = 1:numel(sp_ids)
        comb_ids = changem(comb_ids, idv, sp_ids(idv));
    end
end
vfov_qval_polys = [mb.flattenPolygon(sensor_visibility_polygons(flt_svp)), contour_plys_chng{:}];
num_vfovs = sum(flt_svp);
num_comb = size(comb_ids, 1);
comb_contour_ids = [(0:num_comb-1)'*2, (0:num_comb-1)'*2+1]+1;

%%%
% poly_combine_jobs = mat2cell(comb_ids, ones(num_comb,1), 2);

% vfov_int_ply = bpolyclip_batch(sensor_visibility_polygons, 1, poly_combine_jobs, bpolyclip_batch_options );

%%
poly_combine_jobs = mat2cell([comb_ids, num_vfovs+comb_contour_ids(:,1); comb_ids, num_vfovs+comb_contour_ids(:,2)], ones(2*num_comb,1), 3);
id_vmax = numel(vfov_qval_polys);
if ~all(cellfun(@(ids) all(ids<=id_vmax), poly_combine_jobs))
    error('Mismatch in jobs');
end

ismerged = false;
issuccess = false;
while ~issuccess
    try
        [bvfov_qval_intersections, bvfov_qval_areas] = bpolyclip_batch(vfov_qval_polys, 1, poly_combine_jobs, 1 );
        issuccess = true;
    catch
        if ~ismerged
            vfov_qval_polys = cellfun(@(p) mb.mergePoints(p, 10), vfov_qval_polys, 'uniformoutput', false);
            ismerged = true;
        else
            error('Mergeing was not successfull');
        end
    end
end
%%
flt_nonempty = cellfun(@(x) ~isempty(x), bvfov_qval_intersections);
bvfov_qval_intersections = bvfov_qval_intersections(flt_nonempty);
flt_size = bvfov_qval_areas(flt_nonempty)>10000;
bvfov_qval_intersections = bvfov_qval_intersections(flt_size);
bvfov_qval_intersections = mb.flattenPolygon(bvfov_qval_intersections);
bvfov_qval_intersections = cellfun(@(p) mb.mergePoints(p, 10), bvfov_qval_intersections, 'uniformoutput', false);
bvfov_qval_intersections = bvfov_qval_intersections(~cellfun(@isempty, bvfov_qval_intersections));
%%
% ply_all = [ply_to_cover, bvfov_qval_intersections];
% [ply_remaining, area_remaining] = bpolyclip_batch(ply_all , 0, 1:numel(ply_all));
%%
ptmp = ply_to_cover_dbl;
idi = 1;
ide = 1;
idle = 0;
area_remaining = area_to_cover;
%%%
while idi <= numel(bvfov_qval_intersections) && ~isempty(ptmp)
    try
        %%
        [ptmp, area_remaining] = bpolyclip(ptmp, double(bvfov_qval_intersections{idi}), 0);
        %         ptmp = bpolyclip(ptmp, ptmp, 1, 0, 100);
        idi = idi+1;
        %
    catch
        ptmp = cellfun(@(p) mb.mergePoints(p, 10), ptmp, 'uniformoutput', false);
        if idle ~= idi
            idle = idi;
            ide = 0;
        else
            ide = ide+1;
        end
        if ide > 5
            error('could not fix poly');
        end
        %         %     pause;
    end
end
% covered_ply = bpolyclip_batch(bvfov_qval_intersections, 3, 1:numel(bvfov_qval_intersections), 1);
% for idbv = 1:numel(bvfov_qval_intersections)
%     covered_ply = bpolyclip(covered_ply, bvfov_qval_intersections{idbv}{1}, 3 );
% end
%%
% covered_ply = cellfun(@(p) mb.mergePoints(p, 10), covered_ply, 'uniformoutput', false);
% [ply_remaining, area_remaining] = bpolyclip(ply_to_cover, covered_ply , 0);
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
name = 'conference_room';
% name = 'large_flat';
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

