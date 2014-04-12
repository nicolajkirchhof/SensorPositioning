function [ bpoly ] = visilibity2boost( vpoly )
%BOOST2VISILIBITY Summary of this function goes here
%   Detailed explanation goes here
%extract all rings
if ~iscell(vpoly)
    bpoly = int64([vpoly', vpoly(1,:)']);
    return;
end

bpoly = {};
for idp = 1:numel(vpoly)
    bpoly{idp} = mb.visilibity2boost(vpoly{idp});
end   
