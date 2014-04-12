function bpoly = expandPolygon( bpoly, dist, varargin)
%EXPANDPOLYGON Summary of this function goes here
%   Detailed explanation goes here
% expandRing = @(x) expandPolygon(double(mb.boost2visilibity(x)), dist);
gpoly = mb.correctPolygon2Geom(bpoly);
expandRingDist = @(x) mb.visilibity2boost(expandRing(x, dist));
bpoly = mb.foreachRing(gpoly, expandRingDist);
end

function out_ring = expandRing(in_ring, dist)
    out_rings = expandPolygon(in_ring, dist);
    if numel(out_rings) > 2
        warning('expand returned more than one, using biggest');
        areas = zeros(1,numel(out_rings));
        for idr = 1:numel(out_rings)
            areas(idr) = polygonArea(out_rings{idr});
        end
        [~, idmax] = max(areas);
        out_ring = out_rings{idmax};
    else
        out_ring = out_rings{1};
    end
end