function [ idx ] = getMeasureIdx( scal )
%GETMEASUREPOSE Summary of this function goes here
%   Detailed explanation goes here
idx = 3*scal.numSensors+1:3*scal.numSensors+2*scal.numMeasures;
end

