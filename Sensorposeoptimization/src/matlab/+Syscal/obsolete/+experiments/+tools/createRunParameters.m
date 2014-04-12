function [scal] = createRunParameters(ntc, nsv, mplimits, splimits)

if nargin < 2
    mplimits = [0 0];
end

if nargin < 3
    splimits = [0 0 0];
end

load(ntc);

syscal.plotState(scal);
%scal.state_error = @(x) sum(x.^2);

if iscell(mplimits)
   syscal.addMeasurePoseLimits(scal, mplimits{1}, mplimits{2} ); 
else
    syscal.addMeasurePoseLimits(scal, 'abs', mplimits );
end
syscal.addSensorPoseLimits(scal, 'abs', splimits);

if ischar(nsv)
    syscal.addStateNoiseUni(scal);
else
    load(['sv' num2str(nsv)]);
    scal.stateCurrent = sv;
end
%
h = syscal.plotState(scal);

scal.userData.plotHandle = h;

