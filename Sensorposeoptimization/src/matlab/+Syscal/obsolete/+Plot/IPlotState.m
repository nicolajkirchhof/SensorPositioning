classdef IPlotState < handle
    properties
        h
        hold
    end
    methods
        function obj = PlotSensorState(h, hold)
            if nargin > 0 && ~isempty(h)
                obj.h = h;
            else
                obj.h = figure;
            end
            if nargin > 1 && ~isempty(hold)
                obj.hold = hold;
            else
                obj.hold = 'off';
            end
        end
        
        function activate(obj)
            % get figure
            h_parent = get(obj.h, 'Parent');
            h_subparent = obj.h;
            while h_parent ~= 0
                h_subparent = h_parent;
                h_parent = get(h_subparent, 'Parent');
            end
            
            set(0, 'CurrentFigure', h_subparent);
            if obj.h ~= h_subparent
                set(h_subparent, 'CurrentAxes', obj.h);
            end
        end
    end
end