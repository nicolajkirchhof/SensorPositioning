classdef IUncertainPose
    %% System Calibration Data
    % Holds the data needed to optimize the sensor positions and orientations
    % from measurements of a single person.
    
    properties
        estimate
        lb
        ub
        reference %[x y z rotx roty rotz]
    end
    
    properties(Dependent)
        Length
    end
    
    methods
        function obj = IUncertainPose()
        end
        
        function length = get.Length(obj)
            length = size(obj.estimate, 1);
        end
        
        function obj = createRandEstimateInBounds(obj)
            obj.estimate = obj.lb + rand(size(obj.lb)).*(obj.ub-obj.lb);
        end
    end
end

