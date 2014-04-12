function [ edges ] = ring2edges( bring )
%RING2EDGES Summary of this function goes here
%   Detailed explanation goes here
edges = double([bring(:,1:end-1)', bring(:,2:end)']);

end

