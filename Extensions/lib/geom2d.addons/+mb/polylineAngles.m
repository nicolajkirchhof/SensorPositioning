function [ angles ] = polylineAngles( bpoly )
%POLYGONVERTICIES Summary of this function goes here
%   Detailed explanation goes here
polys = mb.boost2visilibity(bpoly);
if ~iscell(polys)
    polys = {polys};
end
fun_angles = @(x) angle2Points(x, circshift(x, -1));
angles = cellfun(fun_angles, polys, 'uniformoutput', false);
end



