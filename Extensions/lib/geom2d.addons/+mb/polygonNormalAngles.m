function [ normal_angles, poly_angles ] = polygonNormalAngles( bpoly )
%POLYGONVERTICIES Summary of this function goes here
%   Detailed explanation goes here
poly_angles = mb.polygonAngles(bpoly);
polys = mb.boost2visilibity(bpoly);
extract = false;
if ~iscell(polys)
    polys = {polys};
    extract = true;
end
fun_lineangles = @(x) angle2Points(x, circshift(x,-1));
lineangles = cellfun(fun_lineangles, polys, 'uniformoutput', false);

fun_anglediff = @(x, y) angle(exp(1i*(x+y.*0.5)));
normal_angles = cellfun(fun_anglediff, lineangles, poly_angles, 'uniformoutput', false);

if extract
    normal_angles = cell2mat(normal_angles);
    poly_angles = cell2mat(poly_angles);
end
end

