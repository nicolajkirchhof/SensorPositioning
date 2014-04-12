function [ angles ] = polygonAngles( gpoly )
%POLYGONVERTICIES Summary of this function goes here
%   Detailed explanation goes here
if ~iscell(gpoly)
    gpoly = {gpoly};
end
fun_angles = @(x) angle3Points(circshift(x,-1), x, circshift(x,1) );
angles = cellfun(fun_angles, gpoly, 'uniformoutput', false);
end

