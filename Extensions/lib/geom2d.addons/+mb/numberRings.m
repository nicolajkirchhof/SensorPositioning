function hPoly = numberRings(bpoly, varargin)
%% prints the ring number in every polygon ring
polys = mb.boost2visilibity(bpoly);
poly_center = cellfun(@(ply) polygonCentroid(ply), polys, 'uniformoutput', false);
%%

fun_create_text = @(pt, num) text(pt(1), pt(2), num2str(num));
hpoly = cellfun(fun_create_text, poly_center, num2cell(1:numel(poly_center)));

