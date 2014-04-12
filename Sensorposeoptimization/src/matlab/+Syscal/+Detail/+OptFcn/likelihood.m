function [ y, J ] = likelihood( state, opt_config )
%SENSORTARGETFUNCTION Summary of this function goes here
%   Detailed explanation goes here
% scal = description
% scal.numSensors = n sensors
% scal.numMeasures = m measures
% scal.measure_aoa = {} size(1,m)
% scal.measure_matching = {} size(1,m) m->n
% scal.state_limits = @(x) mean
% scal.record = handleclass
% state = [x_s1 y_s1 phi_s1 ... x_m1 y_m1]
num_measurement_states = numel({'px', 'py'});
num_sensor_states = numel({'sx', 'sy', 'phi'});
xOffset = 1;
yOffset = 2;
phiOffset = 3;


if nargout > 1
    %J = zeros(scal.numEquations, numel(state));
end

%%  TO BE CONTINUED

pixval = opt_config.opt_data.pixval;
idxMeasures = opt_config.opt_data.NumSensors*num_sensor_states;
cnt = 1;
y = [];
for idx_sensor = 1:size(pixval, 1)
    for idx_measure = 1:size(pixval, 2)
        if ~isempty(pixval{idx_sensor,idx_measure})
            likelihood = opt_config.opt_data.sensor_objects{idx_sensor}.likelihood(pixval{idx_sensor, idx_measure}, state(idxMeasures:idxMeasures+1,1));
            norm_likelihood = likelihood * 1;%e2;
            % HACK: if multiple targets, just take maximum likelihood
            norm_likelihood = max(norm_likelihood);
            if norm_likelihood > 0
                y(cnt, 1) = 1-norm_likelihood;
            else
                y(cnt, 1) = 1;
            end
        else
            y(cnt, 1) = 1;
        end
        cnt = cnt+1;
    end
end
cla;
opt_config.opt_data.plot(state);
drawnow;
%pause;
% 
% err = [];
% cnt = 1;
% for i = 1:scal.numMeasures
%     for j = 1:numel(scal.measure_matching{i})
%         snum = scal.measure_matching{i}(j);
%         sobj = scal.state_eval{snum};
%         idxs = numSsrStates*(snum-1);
%         idxm = scal.numSensors*numSsrStates+numMsrStates*(i-1);
%         sx = state(xOffset+idxs);
%         sy = state(yOffset+idxs);
%         phi = state(phiOffset+idxs);
%         px = state(xOffset+idxm);
%         py = state(yOffset+idxm);
%         pixval = scal.measure_pixval{snum}(:,i);
%         
%         sobj.Position = [sx sy 0];
%         sobj.Orientation = [0 0 phi];
%         lh = sobj.likelihood(sobj.evaluate([px py]'), [px py]');
%         if lh==0; lh=eps; end;
%         err(:, cnt) = 1/lh;
%         
%         if nargout > 1
%             for i = 1:scal.numEquations
%             J(cnt, xOffset+idxs) = -(py - sy)/(px - sx)^2;
%             J(cnt, yOffset+idxs) = 1/(px - sx);
%             J(cnt, phiOffset+idxs) = tan(aoa + phi)^2 + 1;
%             J(cnt, xOffset+idxm)= (py - sy)/(px - sx)^2;
%             J(cnt, yOffset+idxm) = -1/(px - sx);
%             end
%         end
%         cnt = cnt + 1;
%     end
% end
% 
% ferr = err(:);
% 
% if nargout < 2
%    y_err = scal.state_error(ferr);
% else
% y_err = ferr;
% end
% 
% 
% 
% if any(strcmp(fieldnames(scal), 'record'))
%     if isempty(scal.record)
%         save initial state
%         saveme.state_vec = scal.state_vec;
%         saveme.err = [];
%         scal.record{1,1} = saveme;
%     end
%     saveme.state_vec = state;
%     saveme.err = err;
%     saveme.y_err = y_err;
%     saveme.ferr = err(:);
%     
%     scal.record{1,end+1} = saveme;
% end
% 
% scal.state_vec = state;
% if scal.plot_state
%     syscal.plotState(scal, scal.plot_handle);
% end

%pause
