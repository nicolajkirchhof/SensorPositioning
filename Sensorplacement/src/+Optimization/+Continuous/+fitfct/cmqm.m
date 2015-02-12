function [ qval ] = cmqm( x )
%cmqcm The first call of this function does the initialization, thus it has to 
% contain an initialization struct x containing:
% .ply = the combined polygon 
% .ply_to_cover = the combined polygon without occupied
% .contours = the contours lookup
% .placeable_edges = all edges where sensors can be placed

persistent bpolyclip_options bpolyclip_batch_options is_initialized default_annulus ...
    fun_sensorfov fun_transform area_to_cover ply ply_to_cover contours placeable_edges ...
    placeable_edgelenghts_scale placeable_edgelenghts_lut placeable_edges_dir config wpn wpn_d ...
    dmax2

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

fun_transform = @(ply,x,y, theta) int64(bsxfun(@plus, [x;y], [cos(theta) -sin(theta); sin(theta)  cos(theta)]*double(ply)));
config = Configurations.Discretization.iterative;
area_to_cover = mb.polygonArea(ply_to_cover);
dmax2 = config.sensor.distance(2)^2;


%%
placeable_edgelenghts_scale = x.placeable_edgelenghts_scale;
placeable_edgelenghts_lut = x.placeable_edgelenghts_lut;
placeable_edges_dir = x.placeable_edges_dir;

wpn = x.wpn;
wpn_d = double(wpn);
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

ids_before = arrayfun(@(x) sum(placeable_edgelenghts_lut<=x), x);
dist_to_first = (x-placeable_edgelenghts_lut(ids_before))*placeable_edgelenghts_scale;
gsp = placeable_edges(ids_before, 1:2) + bsxfun(@times, placeable_edges_dir(ids_before,:), dist_to_first);
sp = [gsp'; phi(:)'*(2*pi)];
%%
% bpolyclip_options = Configurations.Bpolyclip.vfov;
% bpolyclip_batch_options = Configurations.Bpolyclip.combine(bpolyclip_options, true);
% config = Configurations.Discretization.iterative;

% input = Experiments.Diss.conference_room(0, 0);
% sp = input.discretization.sp;
% wpn = input.discretization.wpn;
% ply = input.environment.combined;
%%%
vis_polys = visilibity(sp(1:2, :), ply, 10, 10, 0);
vis_empty_flt = cellfun(@isempty, vis_polys);
%%%
vis_polys = cellfun(@int64, vis_polys(~vis_empty_flt), 'uniformoutput', false);
sp = sp(:, ~vis_empty_flt);

%%
% calculates the sensor fov, the inner ring is defined by the min distance and the outer ring by
% the max distance. Since both rings have the same orientation, the inner is flipped to get a
% polygon
% default_annulus = [0 10000 9928 9715 9362 8876 8262 7531 6691 0;
%                    0 0 1194 2371 3514 4606 5633 6579 7431 0 ];
% default_annulus = mb.createAnnulusSegment(0,0,config.sensor.distance(1), config.sensor.distance(2), 0, config.sensor.fov, config.sensorspace.ringvertices);
% fun_sensorfov = @(x,y,theta) int64(bsxfun(@plus, ([cos(theta) -sin(theta); sin(theta)  cos(theta)]*default_annulus), [x;y]));
sensor_fovs = arrayfun(fun_sensorfov, sp(1,:), sp(2,:), sp(3,:), 'uniformoutput', false);

%%
combined_polys = [vis_polys, sensor_fovs];
% combine vis_polys and sensor_fovs to use batch processing
poly_combine_jobs = mat2cell([1:numel(sensor_fovs); numel(vis_polys)+(1:numel(sensor_fovs))]', ones(numel(sensor_fovs),1), 2);
%%%
[sensor_visibility_polygons] = bpolyclip_batch(combined_polys, 1, poly_combine_jobs, bpolyclip_batch_options );

empty_polys = cellfun(@isempty, sensor_visibility_polygons);
svp = cellfun(@(x) x{1}{1}, sensor_visibility_polygons(~empty_polys), 'uniformoutput', false);

sp_wpn_cell = cellfun(@(x) binpolygon(wpn, x, 1), svp, 'uniformoutput', false);
sp_wpn_flt = cell2mat(sp_wpn_cell');

num_wpn = size(wpn, 2);
sp_wpn = false(numel(empty_polys), num_wpn);
sp_wpn(~empty_polys, :) = sp_wpn_flt;

maxvals = zeros(num_wpn, 1);
%%
for idw = 1:size(wpn, 2)
    %%
    ids = find(sp_wpn(:,idw));
    sc = comb2unique(ids);

    s1_idx = sc(:,1);
    s2_idx = sc(:,2);
    %%
    da2 = sum(bsxfun(@minus, sp(1:2, s1_idx), wpn_d(:,idw)).^2);
    da = sqrt(da2);
    db2 = sum(bsxfun(@minus, sp(1:2, s2_idx), wpn_d(:,idw)).^2);
    db = sqrt(db2);
    dc = sqrt(sum((sp(1:2, s1_idx)-sp(1:2, s2_idx)).^2));
    
    v = 1 - (2 * da2 .* db2 ) ./ ( dmax2 * sqrt( (db-da+dc) .* (da-db+dc) .* (da+db-dc) .* (da+db+dc) ) );
    
%     q_sin = sin(mb.angle3PointsFast(sp(1:2, s1_idx), wpn_d(:,idw), sp(1:2, s2_idx)))';    
%     ds1 = mb.distancePoints(wpn(:,idw), sp(1:2, s1_idx));
%     ds2 = mb.distancePoints(wpn(:,idw), sp(1:2, s2_idx));
%     dn1 = sqrt(sum(bsxfun(@minus, sp(1:2, s1_idx), wpn_d(:,idw)).^2))./dmax;
%     dn2 = sqrt(sum(bsxfun(@minus, sp(1:2, s2_idx), wpn_d(:,idw)).^2))./dmax;
    
%     dn1 = ds1./dmax;
%     dn2 = ds2./dmax;
    
%     v = 1-((dn1.*dn2)'./(q_sin));
    flt_vis = da2>dmax2|db2>dmax2;
    v(flt_vis) = [];
    
    if isempty(v)
        maxvals(idw) = 0;
    else
        maxvals(idw) = max(v);
    end
end

%%
is_penalty = maxvals < 0.45;
penalty = sum(is_penalty)*num_wpn;
qval = -sum(maxvals(~is_penalty))+penalty;


return
%%
% load tmp\conference_room\gco.mat
% clearvars -except gco;
clear functions;
%%%
sol = gco{10, 10};
input = Experiments.Diss.conference_room(sol.num_sp, sol.num_wpn);
opt = Optimization.Continuous.prepare_opt(input, sol.sensors_selected);
opt.wpn = input.discretization.wpn;
%%%%
opt.x = opt.x+0.01;
% opt.phi = opt.phi+0.2;
Optimization.Continuous.fitfct.cmqm(opt)
%%%
x = opt.x+0.01;
phi = opt.phi+0.5;

Optimization.Continuous.fitfct.cmqm([x phi])


