classdef IOptimizationConfig
    %% System Calibration Data
    % Holds the data needed to optimize the sensor positions and orientations
    % from measurements of a single person.
    
    properties (Abstract)
        x0
        ub
        lb
    end
       
    methods
    
    end
end
