function [ qval ] = cmqcm( sp, ply, contours )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

comb_ids = comb2unique(sp);

%% 
% calculate distances, move contours to positions and mirror them on the direct connection 
distances = mb

fun_sensorfov = @(x,y,theta) int64(bsxfun(@plus, ([cos(theta) -sin(theta); sin(theta)  cos(theta)]*default_annulus), [x;y]));
sensor_fovs = arrayfun(fun_sensorfov, sp(1,:), sp(2,:), sp(3,:), 'uniformoutput', false);
b

end

