%% DOCUMENT TITLE
% Holds the record of an optimization process this includes the state
% vector x, the resulting fitness y and, if used, the jacobian J and
% hessian H.
%%
classdef OptimizationRecord < handle
    %RECORD
    %   Detailed explanation goes here
    
    properties
        x_all
        x_
        y_
        y_all
        J_
        H_
        Length_
        Current_
    end
    properties (Dependent)
        x
        y
        J
        H
        Length
        Current
    end
    
    methods
        function obj = OptimizationRecord()
            obj.x_ = {};
            obj.y_ = {};
            obj.J_ = {};
            obj.H_ = {};
            obj.Length_ = 0;
            obj.Current_ = 0;
        end
        function update(obj, x, y, J, H)
            if nargin > 0; obj.x_{end+1} = x; obj.x_all(:, end+1) = x; end;
            if nargin > 1; obj.y_{end+1} = y; obj.y_all(:, end+1) = y; end;
            if nargin > 2; obj.J_{end+1} = J; end;
            if nargin > 3; obj.H_{end+1} = H; end;
            obj.Length_ = obj.Length_ + 1;
            obj.Current_ = obj.Current_ + 1;
        end
        function x = get.x(obj)
            x = obj.x_{obj.Current_};
        end
        function y = get.y(obj)
            y = obj.y_{obj.Current_};
        end
        function J = get.J(obj)
            J = obj.J_{obj.Current_};
        end
        function H = get.H(obj)
            H = obj.H_{obj.Current_};
        end
        function Current = get.Current(obj)
            Current = obj.Current_;
        end
        function set.Current(obj, Current)
            obj.Current_ = Current;
        end
        function Length = get.Length(obj)
            Length = obj.Length_;
        end
        
        function x_all = get.x_all(obj)
            if isempty(obj.x_all)
                % calculate waterfall
                for idx_frame = 1:obj.Length
                    obj.x_all(:, idx_frame) =  obj.x_{idx_frame};
                end
            end
            x_all = obj.x_all;
        end
        
        function y_all = get.y_all(obj)
            if isempty(obj.y_all)
                % calculate waterfall
                for idx_frame = 1:obj.Length
                    obj.y_all(:, idx_frame) =  obj.y_{idx_frame};
                end
            end
            y_all = obj.y_all;
        end
        
        
    end
    
end

