function addStateNoiseUni( scal )
%ADDSTATENOISE Summary of this function goes here
%   Detailed explanation goes here

if isempty(scal.stateLimits)
    %naturally limit to room size of 10mX10m
    limits = [0 0 -pi 10 10 2*pi];
    
    pose = bsxfun(@plus, limits(1, 1:3), bsxfun(@times, limits(1, 4:6),  rand(scal.numSensors, 3)));
    
    syscal.setSensorPose(scal, pose);
    
    measures = bsxfun(@times, limits(1, 4:5),  rand(scal.numMeasures, 2));
    
    syscal.setMeasurePose(scal, measures);   
else
    scal.stateCurrent = scal.stateLimits(:, 1) + rand(size(scal.stateCurrent)).*scal.stateLimits(:,2);    
end


end

