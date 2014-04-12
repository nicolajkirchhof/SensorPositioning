function [ y_err, J ] = checkSensorPoseUpdate( state, scal )
%SENSORTARGETFUNCTION Summary of this function goes here
%   Detailed explanation goes here
% scal = description
% scal.numSensors = n sensors
% scal.numMeasures = m measures
% scal.measureAoa = {} size(1,m)
% scal.measureAssignment = {} size(1,m) m->n
% scal.stateLimitsits = @(x) mean
% scal.record = handleclass
% state = [x_s1 y_s1 phi_s1 ... x_m1 y_m1]
numMsrStates = numel({'px', 'py'});
numSsrStates = numel({'sx', 'sy', 'phi'});
xOffset = 1;
yOffset = 2;
phiOffset = 3;


if nargout > 1
    J = zeros(scal.numEquations, numel(state));
end

err = [];
cnt = 1;
for i = 1:scal.numMeasures
    for j = 1:numel(scal.measureAssignment{i})
        ref = scal.measureAssignment{i}(j);
        idxs = numSsrStates*(ref-1);
        idxm = scal.numSensors*numSsrStates+numMsrStates*(i-1);
        sx = state(xOffset+idxs);
        sy = state(yOffset+idxs);
        phi = state(phiOffset+idxs);
        px = state(xOffset+idxm);
        py = state(yOffset+idxm);
        aoa = scal.measureAoa{i}(j);

		error('ToBeImplemented');

        if nargout > 1
            %for i = 1:scal.numEquations
                J(cnt, xOffset+idxs) = -(py - sy)/(px - sx)^2;
                J(cnt, yOffset+idxs) = 1/(px - sx);
                J(cnt, phiOffset+idxs) = tan(aoa + phi)^2 + 1;
                J(cnt, xOffset+idxm)= (py - sy)/(px - sx)^2;
                J(cnt, yOffset+idxm) = -1/(px - sx);
            %end
        end
        cnt = cnt + 1;
    end
end

if nargout < 2
y_err = scal.state_error(err);
else
    y_err = err;
end



if any(strcmp(fieldnames(scal), 'record'))
    if isempty(scal.record)
        %save initial state
        saveme.stateCurrent = scal.stateCurrent;
        saveme.err = [];
        scal.record{1,1} = saveme;
    end
    saveme.stateCurrent = state;
    saveme.err = err;
    saveme.y_err = y_err;
    
    scal.record{1,end+1} = saveme;
end

scal.stateCurrent = state;
if scal.userData.plotState
    syscal.plotState(scal, scal.userData.plotHandle);
end

%pause
