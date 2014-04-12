function [ measure_pose ] = addMeasurePoseLimits( measure_pose, pose_limits, absolute )
%ADDMEASUREPOSELIMITS Summary of this function goes here
%   Detailed explanation goes here

if absolute
%     idx = 3*measure_pose.numSensors+1:numel(measure_pose.stateCurrent);
%     %pose_gt = syscal.getMeasurePose(measure_pose);
%     room = syscal.getRoomDim(measure_pose);
%     pose_lim(:, 1) = repmat((room(1:2))', measure_pose.numMeasures, 1);
%     pose_lim(:, 2) = repmat((room(3:4))', measure_pose.numMeasures, 1);
%     
%     measure_pose.stateLimits(idx, 1:2) = pose_lim;
else
    num_pose_elements = size(measure_pose.reference, 1);
    measure_pose.lb = bsxfun(@minus, measure_pose.reference, repmat(pose_limits, num_pose_elements, 1));
    measure_pose.ub = bsxfun(@plus, measure_pose.reference, repmat(pose_limits, num_pose_elements, 1));
end

