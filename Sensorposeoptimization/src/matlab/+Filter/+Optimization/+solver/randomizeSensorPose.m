function [ pose ] = randomizeSensorPose( pose, mean )
%RANDOMIZESENSORPOSE Summary of this function goes here
%   Detailed explanation goes here
    pose = repmat(pose,1,2);
    pose(:,4:6) = repmat(mean, size(pose,1),1);
    
end

