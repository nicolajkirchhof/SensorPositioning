classdef IterativeLsqNonlin < Filter.Optimization.RecordedOptimization
    methods
        function [result] = filter(obj, opt_description)
            if ~isa(opt_description, 'Filter.Optimization.IOptimizationConfig')
                error('wrong input format');
            end
            obj.opt_data = opt_description;
            aoas = opt_description.aoas;
            
            
            if obj.Display
            opt_description.plot_figure = figure;
            obj.plot_fcn = @(x) opt_description.plot(x);
            end
            

            for idx_measure = 1:numel(aoas, 2)
                idx_opt_sensors = [];
                for idx_sensors = 1:numel(aoas,1)
                    if ~isempty(aoas{idx_sensors, idx_measure})
                        idx_opt_sensors(end+1) = idx_sensors;
%                         part_state = 
                    end
                end
                
                
                
            end

            [result.state, result.fval, result.exitflag, result.output ] = lsqnonlin(P);
            result.record = obj.record;
            result.opt_description = opt_description;
        end
    end
end

