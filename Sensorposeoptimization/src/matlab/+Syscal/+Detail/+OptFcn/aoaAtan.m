function [ y, J ] = aoaTan( state, opt_config )
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
num_sensor_states = numel({'sx', 'sy', 'phi'});
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
            idxs = num_sensor_states*(idx_sensor-1);
            idxm = opt_config.opt_data.NumSensors*num_sensor_states+(idx_measure-1)*num_measurement_states;
            sx = state(xOffset+idxs);
            sy = state(yOffset+idxs);
            phi = state(phiOffset+idxs);
            px = state(xOffset+idxm);
            py = state(yOffset+idxm);
            aoa = aoas{idx_sensor, idx_measure}(idx_aoa);
            y(cnt) = (phi+aoa)-atan(py-sy)/(px-sx);
            
            if nargout > 1
                %for i = 1:scal.numEquations
                warning('NOT VALID');
                J(cnt, xOffset+idxs) = -(py - sy)/(px - sx)^2;
                J(cnt, yOffset+idxs) = 1/(px - sx);
                J(cnt, phiOffset+idxs) = tan(aoa + phi)^2 + 1;
                J(cnt, xOffset+idxm)= (py - sy)/(px - sx)^2;
                J(cnt, yOffset+idxm) = -1/(px - sx);
                %end
            end
            %             end
            cnt = cnt + 1;
        end
    end
end

opt_config.opt_data.plot(state);
drawnow;
end
%             likelihood = opt_config.opt_data.sensor_objects{idx_sensor}.likelihood(pixval{idx_sensor, idx_measure}, state(idxMeasures:idxMeasures+1,1));
%             norm_likelihood = likelihood * 1e2;
%             % HACK: if multiple targets, just take maximum likelihood
%             norm_likelihood = max(norm_likelihood);
%             if norm_likelihood > 0
%                 y(cnt, 1) = 1-norm_likelihood;
%             else
%                 y(cnt, 1) = 1;
%             end
%         else
%             y(cnt, 1) = 1;
%         end
%         cnt = cnt+1;
%     end
% end
% cla;
% opt_config.opt_data.plot(state);




% for idx_sensor = 1:size(pixval, 1)
%     for idx_measure = 1:size(pixval, 2)
%         if ~isempty(pixval{idx_sensor,idx_measure})
%             likelihood = opt_config.opt_data.sensor_objects{idx_sensor}.likelihood(pixval{idx_sensor, idx_measure}, state(idxMeasures:idxMeasures+1,1));
%             norm_likelihood = likelihood * 1e2;
%             % HACK: if multiple targets, just take maximum likelihood
%             norm_likelihood = max(norm_likelihood);
%             if norm_likelihood > 0
%                 y(cnt, 1) = 1-norm_likelihood;
%             else
%                 y(cnt, 1) = 1;
%             end
%         else
%             y(cnt, 1) = 1;
%         end
%         cnt = cnt+1;
%     end
% end
% cla;
% opt_config.opt_data.plot(state);
%
%
% idxMeasures = opt_config.NumSensors;
% y = [];
% for i = 1:numel(pixval)
%     for j = 1:size(pixval{i},2)
%         likelihood = opt_config.sensor_objects{i}.likelihood(pixval{i}(:, j), state(idxMeasures:idxMeasures+1,1));
%         if likelihood > 0
%
%             obj.correspondences{i}(end+1) = j;
%         else
%             obj.correspondences{i}(end+1) = 1;
%         end
%     end
% end
%
% if nargout > 1
%     J = zeros(scal.numEquations, numel(state));
% end
%
% err = [];
% cnt = 1;
% for i = 1:scal.numMeasures
%     for j = 1:numel(scal.measureAssignment{i})
%         ref = scal.measureAssignment{i}(j);
%         idxs = num_sensor_states*(ref-1);
%         idxm = scal.numSensors*num_sensor_states+num_measurement_states*(i-1);
%         sx = state(xOffset+idxs);
%         sy = state(yOffset+idxs);
%         phi = state(phiOffset+idxs);
%         px = state(xOffset+idxm);
%         py = state(yOffset+idxm);
%         aoa = scal.measureAoa{i}(j);
%         err(end+1) = tan(phi+aoa)-(py-sy)/(px-sx);
%         if nargout > 1
%             %for i = 1:scal.numEquations
%                 J(cnt, xOffset+idxs) = -(py - sy)/(px - sx)^2;
%                 J(cnt, yOffset+idxs) = 1/(px - sx);
%                 J(cnt, phiOffset+idxs) = tan(aoa + phi)^2 + 1;
%                 J(cnt, xOffset+idxm)= (py - sy)/(px - sx)^2;
%                 J(cnt, yOffset+idxm) = -1/(px - sx);
%             %end
%         end
%         cnt = cnt + 1;
%     end
% end
%
% %if nargout < 2
% %$    y_err = scal.state_error(err);
% %else
%  y_err = err;
% %end
%
%
% scal.stateCurrent = state;
% if scal.userData.plotState
%     syscal.plotState(scal, scal.userData.plotHandle);
% end
%
% %pause
