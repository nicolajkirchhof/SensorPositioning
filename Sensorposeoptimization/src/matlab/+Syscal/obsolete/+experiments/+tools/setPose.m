function [ scal ] = setPose( scal, pose )
%SETSENSORPOSE Summary of this function goes here
%   Detailed explanation goes here

scal.sensorReference = pose;
pose = pose';
scal.stateCurrent(1:numel(pose),1) = pose(:); 
scal.stateReference(1:numel(pose),1) = pose(:); 

end

