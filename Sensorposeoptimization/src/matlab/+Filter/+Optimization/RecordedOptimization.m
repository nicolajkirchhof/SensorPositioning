classdef RecordedOptimization < handle
    %% System Calibration Data
    % Holds the data needed to optimize the sensor positions and orientations
    % from measurements of a single person.
    
    properties
        objective_opt
        opt_data
        options
        record
        solver
        user_data
        x_all
        plot_fcn
        Display
    end
    
    properties (Dependent)
        objective
        x0
        ub
        lb
    end
    
    methods
        function obj = RecordedOptimization(param)
            obj.record = Filter.Optimization.OptimizationRecord;
            
            if nargin < 1; return; end
            fn = fieldnames(param);
            fno = fieldnames(obj);
            for i = 1:numel(fn)
                if any(strcmpi(fno, fn{i}))
                    obj.(lower(fn{i})) = param.(fn{i});
                end
            end
        end
        
        
        function set.objective(obj, objective)
            obj.objective_opt = objective;
        end
        
        function objective = get.objective(obj)
            objective = @obj.optfctx;
        end
        
        function [y, J, H] = optfctx(obj, x)
            %OPTFCT Summary of this function goes here
            %   Detailed explanation goes here
            switch nargout
                case 1
                    [y] = obj.objective_opt(x, obj);
                    J = [];
                    H = [];
                case 2
                    [y, J] = obj.objective_opt(x, obj);
                    H = [];
                case 3
                    [y, J, H] = obj.objective_opt(x, obj);
            end
            obj.record.update(x, y, J, H);
        end
        
        function prepareOptimization(obj, opt_description)
            obj.fct = opt_description;
        end
        
        function x0 = get.x0(obj)
            x0 = obj.opt_data.x0;
        end
        
        function lb = get.lb(obj)
            lb = obj.opt_data.lb;
        end
        
        function ub = get.ub(obj)
            ub = obj.opt_data.ub;
        end
        
        function problem = getProblemStruct(obj)
            problem.objective = obj.objective;
            problem.x0 = obj.x0;
            problem.A = [];
            problem.b = [];
            problem.Aeq = [];
            problem.beq = [];
            problem.lb = obj.lb;
            problem.ub = obj.ub;
            problem.nonlcon = [];
            problem.solver = obj.solver;
            problem.options = obj.options;
        end
        
        function problem = getProblemStructCmaes(obj)
            problem = obj.options;
            problem.LBounds = obj.lb;
            problem.UBounds = obj.ub;
        end
        
        function replay(obj, from_frame, to_frame)
            if nargin < 2
                from_frame = 1;
            end
            if nargin < 3
                to_frame = obj.record.Length;
            end
            obj.opt_data.plot_figure = figure;
            
            overview = figure;
            subplot(2,1,1), imagesc(obj.record.x_all(:, from_frame:to_frame)); 
            subplot(2,1,2), imagesc(obj.record.y_all(:, from_frame:to_frame));
            
            bars = figure;
            pause;
            set(0, 'CurrentFigure', bars);
            for idx_frame = from_frame:to_frame
                obj.record.Current = idx_frame;
                subplot(2, 1, 1);
                bar(obj.record.x)
                subplot(2, 1, 2);
                bar(obj.record.y)
                obj.opt_data.plot(obj.record.x);
                drawnow;
                disp(idx_frame);
                %pause;
            end
            
        end
        
    end
end
