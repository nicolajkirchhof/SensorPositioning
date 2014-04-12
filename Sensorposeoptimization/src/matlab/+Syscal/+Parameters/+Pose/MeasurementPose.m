classdef MeasurementPose < Syscal.Parameters.Pose.IUncertainPose
    %% System Calibration Data
    % Holds the data needed to optimize the sensor positions and orientations
    % from measurements of a single person.
    
    properties
        room
        position_variance = 'room';
    end
    
    properties(Dependent)
        PositionVariance
		PoseVariance
    end
    
    methods
        function obj = MeasurementPose(reference, room)
            
        end
        function plot(obj)
            if ~isempty(obj.estimate)
                plot(obj.estimate(:, 1),obj.estimate(:,2),'x');
            end
            if ~isempty(obj.reference)
                plot(obj.reference(:, 1), obj.reference(:,2), 'o');
            end
        end
        
        function obj = set.PositionVariance(obj, position_variance)
            num_pose_elements = size(obj.reference, 1); 
            obj = updatePositionVariance(obj, position_variance, num_pose_elements);
        end
		
		function obj = set.PoseVariance(obj, pose_variance)
            num_pose_elements = size(obj.reference, 1); 
			position_variance = pose_variance(1:num_pose_elements, 1:3);
            obj = updatePositionVariance(obj, position_variance, num_pose_elements);
        end
        
        function obj = updatePositionVariance(obj, position_variance, num_pose_elements)
             if ischar(position_variance)
                obj.lb = repmat([obj.room.Minimum' 0 0 0 0], num_pose_elements, 1);
                obj.ub = repmat([obj.room.Maximum' 0 0 0 0], num_pose_elements, 1);
            else
                obj.lb = bsxfun(@minus, obj.reference, repmat(position_variance, num_pose_elements, 1));
                obj.ub = bsxfun(@plus, obj.reference, repmat(position_variance, num_pose_elements, 1));
             end  
        end
		
       
        function var = get.PositionVariance(obj)
            var = obj.position_variance;
        end
		
		function var = get.PoseVariance(obj)
            var = obj.position_variance;
        end
		
    end
    
    methods (Access = private)
    end
    
    
end

