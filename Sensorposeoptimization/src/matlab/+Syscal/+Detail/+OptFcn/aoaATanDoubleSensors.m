function [ y, J ] = aoaATanDoubleSensors( state, opt_config )
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
num_measurement_states = numel({'px', 'py'});
num_sensor_states = numel({'sx', 'sy', 'phi1', 'phi1'});
xOffset = 1;
yOffset = 2;
phiOffset = 3;

pixval = opt_config.opt_data.pixval;
aoas = opt_config.opt_data.aoas;
idxMeasures = opt_config.opt_data.NumSensors*num_sensor_states;
cnt = 1;
y = [];
if nargout > 1
    J = [];
end

for idx_sensor = 1:size(aoas, 1)
    for idx_measure = 1:size(aoas, 2)
        %         if ~isempty(aoas{idx_sensor,idx_measure})
        for idx_aoa = 1:2:numel(aoas{idx_sensor,idx_measure})
            idxs = num_sensor_states*(round(idx_sensor/2)-1);
            idxm = opt_config.opt_data.NumSensors*num_sensor_states+(idx_measure-1)*num_measurement_states;
            sx = state(xOffset+idxs);
            sy = state(yOffset+idxs);
            phi = state(phiOffset+idxs+mod(idx_sensor+1,2));
            px = state(xOffset+idxm);
            py = state(yOffset+idxm);
            aoa = aoas{idx_sensor, idx_measure}(idx_aoa);
            %y(cnt) = tan(phi+aoa)-(py-sy)/(px-sx);
            %err = (phi+aoa)-atan2((py-sy),(px-sx));
            err = Math.Circular.diff((phi+aoa), atan2((py-sy),(px-sx)));
            y(cnt) = err;
            if nargout > 1
                %for i = 1:scal.numEquations
                J(cnt, xOffset+idxs) =  -(py - sy)/((px - sx)^2*((py - sy)^2/(px - sx)^2 + 1));
                J(cnt, yOffset+idxs) =1/((px - sx)*((py - sy)^2/(px - sx)^2 + 1));
                J(cnt, phiOffset+idxs+mod(idx_sensor+1,2)) = 1;
                J(cnt, xOffset+idxm)= (py - sy)/((px - sx)^2*((py - sy)^2/(px - sx)^2 + 1));
                J(cnt, yOffset+idxm) = -1/((px - sx)*((py - sy)^2/(px - sx)^2 + 1));
%                 J(cnt, xOffset+idxs) = -(py - sy)/(px - sx)^2;
%                 J(cnt, yOffset+idxs) = 1/(px - sx);
%                 J(cnt, phiOffset+idxs+mod(idx_sensor+1,2)) = tan(aoa + phi)^2 + 1;
%                 J(cnt, xOffset+idxm)= (py - sy)/(px - sx)^2;
%                 J(cnt, yOffset+idxm) = -1/(px - sx);
                %end
            end
            %             end
            cnt = cnt + 1;
        end
    end
end

if strcmp(opt_config.solver, 'cmaes')
    y = sqrt(y*y');
end

if ~isempty(opt_config.plot_fcn)
    opt_config.plot_fcn(state);
    drawnow;
end
end
