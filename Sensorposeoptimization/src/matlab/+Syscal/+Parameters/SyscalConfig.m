classdef SyscalConfig < Filter.Optimization.IOptimizationConfig
    %OPTIMIZATIONSTATE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        measure_pose
        sensor_pose
        aoas
        pixval
        pixval_normalized
        sensor_objects
        preprocessors
        ValidSamples
        plot_figure
        state_reference
        physical_representation = 'single' % double single sensors
        Bounded = true;
    end
    
    properties (Dependent)
        x0
        ub
        lb
        reference
        StateReference
        NumSensors
        NumMeasures
    end
    
    methods
        function obj = SyscalConfig(measure_pose, sensor_pose, sensor_objects, preprocessors, pixval, normed)
            if nargin < 1; return; end;
            if nargin < 6; normed = false; end;
            obj.measure_pose = measure_pose;
            obj.sensor_pose = sensor_pose;
            obj.sensor_objects = sensor_objects;
            obj.preprocessors = preprocessors;
            obj.ValidSamples = 0;
            obj.pixval = {};
            
            if ~normed
                for i = 1:numel(pixval)
                    for sample_idx = 1:size(pixval{i}, 1)
                        for j = 1:100, obj.pixval{i, sample_idx} = preprocessors{i}.apply(pixval{i}(sample_idx,:)'); end
                        if ~isempty(obj.pixval{i, sample_idx})
                            obj.ValidSamples = obj.ValidSamples + 1;
                        end
                    end
                end
            else
                for i=1:size(aoas,1)
                    for j=1:size(aoas,2)
                        if ~isempty(aoas{i,j})
                            obj.ValidSamples = obj.ValidSamples + 1;
                        end
                    end
                end
                obj.pixval = pixval;
            end
            
        end
        
        function obj = normalizePixvals(obj)
            obj.ValidSamples = 0;
            for idx_sensor = 1:size(obj.pixval,1)
                for idx_measure = 1:size(obj.pixval, 2)
                    for j = 1:120,
                        obj.pixval_normalized{idx_sensor, idx_measure} = obj.preprocessors{idx_sensor}.apply(obj.pixval{idx_sensor, idx_measure});
                    end
                    if ~isempty(obj.pixval_normalized{idx_sensor, idx_measure})
                        obj.ValidSamples = obj.ValidSamples + 1;
                    end
                end
            end
        end
        
        function obj = set.aoas(obj, aoas)
            obj.aoas = aoas;
            obj.measure_pose = obj.measure_pose.updatePositionVariance(obj.measure_pose.position_variance, size(aoas, 2));
        end
        
        function obj = calculateAoas(obj)
            filter = ThILo.Detail.PreProcessor.AoaExtractor;
            for idx_sensor = 1:size(obj.pixval_normalized,1)
                filter.Sensor = obj.sensor_objects{idx_sensor};
                for idx_measure = 1:size(obj.pixval_normalized, 2)
                    obj.aoas{idx_sensor,idx_measure} = filter.apply(obj.pixval_normalized{idx_sensor, idx_measure});
                end
            end
        end
        
        function x0 = get.x0(obj)
            if isempty(obj.measure_pose.estimate)
                obj.measure_pose = createRandEstimateInBounds(obj.measure_pose);
            end
            if isempty(obj.sensor_pose.estimate)
                obj.sensor_pose = createRandEstimateInBounds(obj.sensor_pose);
            end
            
            mx0 = obj.measure_pose.estimate(:,1:2)';
            sx0 = obj.sensor_pose.estimate(:,[1,2,6])';
            
            if strcmpi(obj.physical_representation, 'double')
                sx0 = obj.single2doubleSensorState(sx0);
            end
            x0 = [sx0(:); mx0(:)];
        end
        
        function state = single2doubleSensorState(obj, state)
            cnt = 1;
            for idx_sensor = 1:2:obj.NumSensors*2
                flt(cnt:cnt+3) = [idx_sensor*3-2:idx_sensor*3, idx_sensor*3+3];
                cnt = cnt+4;
            end
            state = state(:);
            state = state(flt,1);
        end
        
        function ub = get.ub(obj)
            if ~obj.Bounded; ub = []; return; end;
            mub = obj.measure_pose.ub(:,1:2)';
            sub = obj.sensor_pose.ub(:,[1,2,6])';
            
            if strcmpi(obj.physical_representation, 'double')
                sub = obj.single2doubleSensorState(sub);
            end
            ub = [sub(:); mub(:)];
        end
        
        function lb = get.lb(obj)
            if ~obj.Bounded; lb = []; return; end;
            mlb = obj.measure_pose.lb(:,1:2)';
            slb = obj.sensor_pose.lb(:,[1,2,6])';
            
            if strcmpi(obj.physical_representation, 'double')
                slb = obj.single2doubleSensorState(slb);
            end
            lb = [slb(:); mlb(:)];
        end
        
        function reference = get.reference(obj)
            reference = [obj.sensor_pose.reference; obj.measure_pose.reference];
        end
        
        function num_sensors = get.NumSensors(obj)
            if strcmpi(obj.physical_representation, 'double')
                num_sensors = numel(obj.sensor_objects)/2;
            else
                num_sensors = numel(obj.sensor_objects);
            end
        end
        
        function num_measures = get.NumMeasures(obj)
            num_measures = max([size(obj.aoas, 2), size(obj.pixval_normalized, 2)]);
        end
        
        function state = double2singleSensorState(obj, state)
                cnt = 1;
                flt = [];
                for idx_sensor = 1:2:obj.NumSensors*2
                    flt(cnt:cnt+3) = [idx_sensor*3-2:idx_sensor*3, idx_sensor*3+3];
                    cnt = cnt+4;
                end
                %%
                flt = [flt, flt(end)+1:flt(end)+obj.NumMeasures*2];
                state_n(flt) = state;
                for idx_sensor = 2:2:obj.NumSensors*2
                    state_n(idx_sensor*3-2:idx_sensor*3-1) = state_n(idx_sensor*3-5:idx_sensor*3-4);
                end
                state = state_n';
        end
        
        function plot(obj, state, overwrite)
            if isempty(obj.plot_figure)
                obj.plot_figure = figure;
            end
            if nargin < 3 || overwrite == true
                curr_fig = get(0, 'CurrentFigure');
                set(0, 'CurrentFigure', obj.plot_figure);
                cla;
            end
            
            num_sensors = obj.NumSensors;
            
            if strcmpi(obj.physical_representation, 'double')
                state = obj.double2singleSensorState(state);
                num_sensors = obj.NumSensors*2;
            end
            
            fov_2 = Mltools.deg2rad(24);
            length = 3;
            colors = hsv(num_sensors);
            sensors = {};
            cnt = 1;
            for i = 1:3:num_sensors*3
                pix_geom_points = geom2d.circleArcAsCurve(...
                    [state(i,1)...
                    ,state(i+1,1)...
                    ,length...
                    ,state(i+2,1)-fov_2...
                    ,state(i+2,1)+fov_2]...
                    ,100);
                % add sensor origin as last point
                pix_geom_points(end+1, :) = [state(i,1), state(i+1,1)]; %#ok<AGROW>
                
                
                sensors{cnt} = geom2d.fillPolygon(pix_geom_points,...
                    colors(cnt,:));
                alpha(sensors{end}, 0.3);
                cnt = cnt+1;
                hold on;
                %colors(((i-1)*rsp.sensor_config.pixgeom(2))+pixi,:));
            end
            
            plot(state(num_sensors*3+1:2:end, 1),state(num_sensors*3+2:2:end,1),'x');
            
            if ~isempty(obj.measure_pose.reference)
                plot(obj.measure_pose.reference(:, 1), obj.measure_pose.reference(:,2), 'o');
            end
            
            set(0, 'CurrentFigure', curr_fig);
        end
        
        function reference_diff = calculateReferenceDiff(obj, state)
             num_sensors = obj.NumSensors;
            if strcmpi(obj.physical_representation, 'double')
                num_sensors = obj.NumSensors*2;
            end
            state_diff = state-obj.StateReference;
            reference_diff(:, [1,2,6]) = reshape(state_diff(1:num_sensors*3,1), 3, [])';
            reference_diff(end+1:end+obj.NumMeasures, [1,2]) = reshape(state_diff(num_sensors*3+1:end,1), 2, [])';
        end
        
        function StateReference = get.StateReference(obj)
            sensor_state = obj.sensor_pose.reference(:, [1,2,6])';
            sensor_state = sensor_state(:);
            measure_state = obj.measure_pose.reference(:, 1:2)';
            measure_state = measure_state(:);
            
            StateReference = [sensor_state; measure_state];
        end
        
        function displayState(obj, state)
            num_sensors = obj.NumSensors;
            
            if strcmpi(obj.physical_representation, 'double')
                %%
                cnt = 1;
                for idx_sensor = 1:num_sensors
                str = sprintf('Sensor %d, x=%.3f y=%.3f phi1=%.4f, phi2=%.4f', idx_sensor, state(cnt), state(cnt+1), state(cnt+2), state(cnt+3));
                
                disp(str);
                
                str = sprintf('[%.3f; %.3f; 1.4; 0; 0; %.4f]', state(cnt), state(cnt+1), state(cnt+2));
                disp(str);
                str = sprintf('[%.3f; %.3f; 1.4; 0; 0; %.4f]', state(cnt), state(cnt+1), state(cnt+3));
                disp(str);
                cnt = cnt+4;
                end
                else
                    
                num_sensors = obj.NumSensors*2;
            end
        end
        
        function displaySummary(obj, state)
            
            num_sensors = obj.NumSensors;
            if strcmpi(obj.physical_representation, 'double')
                state = obj.double2singleSensorState(state);
                num_sensors = obj.NumSensors*2;
            end
            
            ref_diff = obj.calculateReferenceDiff(state);
            Sx.values = ref_diff(1:num_sensors, 1);
            Sy.values = ref_diff(1:num_sensors, 2);
            Sphi.values = ref_diff(1:num_sensors, 6);
            Px.values = ref_diff(num_sensors+1:end, 1);
            Py.values = ref_diff(num_sensors+1:end, 2);
            fn = {'Sx', 'Sy', 'Sphi', 'Px', 'Py'};
            stats = {'mean', 'median', 'max', 'min', 'std'};
            
            disp('Value |  Mean  |  Median | Max | Min | std');
            for idx_name = 1:numel(fn)
                str = 'disp([fn{idx_name} ''|'' ';
                for idx_stat = 1:numel(stats)
                    eval([fn{idx_name} '.' stats{idx_stat} '=' stats{idx_stat} '(' fn{idx_name} '.values);']);
                    str = [str 'num2str(' fn{idx_name} '.' stats{idx_stat} ') '' | '' '];
                end
                str = [str ']);'];
                eval(str);
            end
            
        end
        
    end
    
    
end

