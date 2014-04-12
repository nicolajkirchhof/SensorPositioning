classdef SensorPose < Syscal.Parameters.Pose.IUncertainPose
    %% System Calibration Data
    % Holds the data needed to optimize the sensor positions and orientations
    % from measurements of a single person.
    
    properties
    sensor_config
    end
    
    methods
        function obj = SensorPose()

        end
        
        function obj = set.sensor_config(obj, sensor_config)
           for i = 1:numel(sensor_config)
                obj.reference(i,:) = sensor_config{i}.Pose';
                obj.lb(i,:) = sensor_config{i}.Pose'-sensor_config{i}.PoseVariance';
                obj.ub(i,:) = sensor_config{i}.Pose'+sensor_config{i}.PoseVariance';
           end 
        end
        
        function init(obj)
            obj.calculateAoas(obj.measure_pixval);
            obj.initDescription();
        end
        
        
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
        
        function obj = initDescription(obj)
            i = 1;
            while i < 3*obj.num_sensors
                obj.description{i,1} = ['x_s' num2str(s)];
                i = i+1;
                obj.description{i,1} = ['y_s' num2str(s)];
                i = i+1;
                obj.description{i,1} = ['phi_s' num2str(s)];
                i = i+1;
                s = s+1;
            end
        end
    end
    
    methods (Access = private)
    end
    
    
end

