function [ normal_angles, poly_angles ] = polygonNormalAngles( gpoly )
%POLYGONVERTICIES Summary of this function goes here
%   Detailed explanation goes here
poly_angles = polygonAngles(gpoly);
extract = false;
if ~iscell(gpoly)
    gpoly = {gpoly};
    extract = true;
end
fun_lineangles = @(x) angle2Points(x, circshift(x,-1));
lineangles = cellfun(fun_lineangles, gpoly, 'uniformoutput', false);

fun_anglediff = @(x, y) angle(exp(1i*(x+y.*0.5)));
normal_angles = cellfun(fun_anglediff, lineangles, poly_angles, 'uniformoutput', false);

if extract
    normal_angles = cell2mat(normal_angles);
    poly_angles = cell2mat(poly_angles);
end
end

