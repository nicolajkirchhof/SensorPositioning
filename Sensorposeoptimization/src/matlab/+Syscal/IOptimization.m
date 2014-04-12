classdef Syscal < handle & mltools.templates.ITwoAxesVisualization
%% System Calibration Data 
% Holds the data needed to optimize the sensor positions and orientations
% from measurements of a single person.
    
    properties
        measurement_state
        sensor_state
        
        solver
        options
        record
    end
    
    properties(Dependent)
        state_len
        Length
        Current
    end
    
    methods
        function obj = Syscal()
        end
        
        function init(obj)
            obj.calculateAoas(obj.measure_pixval);
            obj.initDescription();
        end
        
        function num = get.state_len(obj)
            num = 3*obj.num_sensors+2*obj.num_measures;
        end
        function set.state_len(obj, value)
        end
        function Length = get.Length(obj)
            Length = numel(obj.record);
        end
        %% Overridden Methods
        
        function gotoFrame(obj, num)
            obj.numCurrentFrame = num;
        end
        
        function drawAxes(obj, axesId, handle)
            if any(axesId == 1)
                syscal.plotState(scal, handle(1), obj.record{obj.numCurrentFrame}.state_vec);
            end
            if any(axeId == 2)
                bar(handle(2), obj.record{obj.numCurrentFrame}.y_err);
            end
        end
        
        function [ dims ] = getRoomDim( scal )
        x_states = scal.stateCurrent(1:3:scal.numSensors*3);
        y_states = scal.stateCurrent(2:3:scal.numSensors*3);

        dims = [min(x_states) min(y_states) max(x_states)-min(x_states) max(y_states)-min(y_states)];

        end
        
        function aoas = calculateAoas(obj, measurements)
            error('to be implemented');
        end
        
    end
    
    methods (Access = private)
    end
    
    
end

