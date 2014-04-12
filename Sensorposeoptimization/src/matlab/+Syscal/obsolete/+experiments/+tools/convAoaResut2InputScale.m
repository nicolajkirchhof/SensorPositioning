function [ res, offset_vec ] = checkResult( scal )
%CHECKRESULT Summary of this function goes here
%   Detailed explanation goes here
    offset = scal.stateReference(1:3,1)-scal.stateCurrent(1:3,1);
    offset_vec = [repmat(offset, scal.numSensors,1); repmat(offset(1:2,1), scal.numMeasures,1)];
    res = scal.stateCurrent+offset_vec;

end

