function [E_r] = calculateRadialEdges(E_r, gpoly)

if isempty(E_r)
    return;
end

is_cell = iscell(E_r);
if ~is_cell
    E_r = {E_r};
    
end

for id_er = 1:numel(E_r)
    e_r = E_r{id_er};
    e_r_xings_cell = cellfun(@(x) intersectRayPolygon(createRay(e_r.begin, e_r.normal), x), gpoly(:), 'uniformoutput', false)';
    flt_nonempty = cellfun(@(x) ~isempty(x),  e_r_xings_cell);
    e_r_xings = cell2mat(e_r_xings_cell(flt_nonempty(:))');
    
    e_r_dists = distancePoints(e_r.begin, e_r_xings);
    [~, e_r_xing_id] = min(e_r_dists(e_r_dists > 1));
    e_r.edge = [e_r.begin, e_r_xings(e_r_xing_id, :)];
    e_r.end = e_r_xings(e_r_xing_id, :);
    E_r{id_er} = e_r;
end

if ~is_cell
    E_r = E_r{1};
end