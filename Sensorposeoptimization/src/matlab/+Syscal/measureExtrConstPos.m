function [ outData ] = measureExtrConstPos(inData, inPositions)
%MEASUREEXTRCONSTPOS Summary of this function goes here
%   Detailed explanation goes here

refdiff = [[1,1,1] ; diff(inPositions)];
refidx = ~(refdiff(:,1)|refdiff(:,2)|refdiff(:,3));

outData = ref.data(refidx, :);
inData;

end

