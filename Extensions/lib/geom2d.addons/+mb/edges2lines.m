function [ lines ] = edges2lines( edges )
%EDGELENGTH Summary of this function goes here
%   Detailed explanation goes here
lines = [edges(:, 1:2) edges(:, 3:4)-edges(:, 1:2)];

end

