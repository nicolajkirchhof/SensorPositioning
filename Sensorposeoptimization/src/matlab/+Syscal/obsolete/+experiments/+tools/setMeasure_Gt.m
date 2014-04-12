function  setMeasure_Gt( scal, measures )
%SETMEASUREPOSE Summary of this function goes here
%   Detailed explanation goes here

    measures = measures';
    scal.stateCurrent(3*scal.numSensors+1:end,1) = measures(:);
    scal.stateReference(3*scal.numSensors+1:end,1) = measures(:);
    scal.measureReference = measures';
end

