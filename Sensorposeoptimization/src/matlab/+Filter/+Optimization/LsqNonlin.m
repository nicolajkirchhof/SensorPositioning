classdef LsqNonlin < Filter.Optimization.RecordedOptimization
    methods
        function [result] = filter(obj, opt_description)
            if ~isa(opt_description, 'Filter.Optimization.IOptimizationConfig')
                error('wrong input format');
            end
            obj.opt_data = opt_description;
            
            if obj.Display
            opt_description.plot_figure = figure;
            obj.plot_fcn = @(x) opt_description.plot(x);
            end
            
            P = obj.getProblemStruct;
            [result.state, result.fval, result.exitflag, result.output ] = lsqnonlin(P);
            result.record = obj.record;
            result.opt_description = opt_description;
        end
    end
end
