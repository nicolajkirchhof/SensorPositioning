function [ scal ] = addSensorPoseLimits( scal, prop, value )
%ADDSTATELIMITS Summary of this function goes here
%   Detailed explanation goes here
%prop = {(abs)olute, (pct)percentage}

switch lower(prop)
    case 'abs'
        pose_gt = scal.stateReference(syscal.getSensorIdx(scal));
        values_half = repmat((value/2)', scal.numSensors, 1);
        pose_lim(:,1) =  pose_gt - values_half;
        pose_lim(:,2) =  2*values_half;
        
        scal.stateLimits(1:3*scal.numSensors, 1:2) = pose_lim;
        
    case 'pct'
        error('To be implemented if needed');

end

    


end

