function sp = opt_vect_to_sp(x, opt_cfg)
%% converts the opt_vect( x ; phi ) to sensor positions
placeable_edgelenghts_scale = opt_cfg.placeable_edgelenghts_scale;
placeable_edgelenghts_lut = opt_cfg.placeable_edgelenghts_lut;
placeable_edges_dir = opt_cfg.placeable_edges_dir;
placeable_edges = opt_cfg.placeable_edges;

id_mid = numel(x)/2;
phi = x(id_mid+1:end);
x = x(1:id_mid);
phi = phi(:);
x = x(:);

ids_before = arrayfun(@(x) sum(placeable_edgelenghts_lut(1:end-1)<x), x);
dist_to_first = (x-placeable_edgelenghts_lut(ids_before))*placeable_edgelenghts_scale;
gsp = placeable_edges(ids_before, 1:2) + bsxfun(@times, placeable_edges_dir(ids_before,:), dist_to_first);
sp = [gsp'; phi(:)'*(2*pi)];