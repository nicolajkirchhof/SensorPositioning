function [ verticies ] = polygonVerticies( bpoly )
%POLYGONVERTICIES Summary of this function goes here
%   Detailed explanation goes here
if iscell(bpoly)
polys = mb.boost2visilibity(bpoly);
verticies = cell2mat(polys');
else
    verticies = double(bpoly');
end

