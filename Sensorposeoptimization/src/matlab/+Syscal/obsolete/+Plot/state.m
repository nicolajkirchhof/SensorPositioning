function [ h ] = plotState( scal, h, state_vec  )
%PLOTSTATE Summary of this function goes here
%   Detailed explanation goes here
    
    if nargin > 1 && ~isempty(h) 
        % get figure
        h_parent = get(h, 'Parent');
        h_subparent = h;
        while h_parent ~= 0 
        h_subparent = h_parent;
        h_parent = get(h_subparent, 'Parent');
        end
            
        set(0, 'CurrentFigure', h_subparent);
        if h ~= h_subparent
           set(h_subparent, 'CurrentAxes', h);
        end
    else
        h = figure;
    end;
    
    cla;
    if nargin < 3
        state_vec = scal.stateCurrent;
    end
    
    s_pose = reshape(state_vec(1:scal.numSensors*3), 3, scal.numSensors)';
    hold on;
    syscal.plotSensorPose(s_pose);
    
    m_pose = reshape(state_vec(scal.numSensors*3+1:end), 2, [])';
    plot(m_pose(:,1),m_pose(:,2),'x');
    plot(scal.measureReference(:,1), scal.measureReference(:,2), 'o');

end

