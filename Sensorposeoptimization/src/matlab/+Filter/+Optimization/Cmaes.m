classdef Cmaes < Filter.Optimization.RecordedOptimization
    properties
        sigma = 1;
    end
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
                
            if opt_description.Bounded
            options.LBounds = opt_description.lb;
            options.UBounds = opt_description.ub;
            obj.options = options;
            [result.state, result.fval, result.counteval, ...
                result.stopflag, result.output, result.bestever ]...
                = Filter.Optimization.solver.cmaes(@(x) obj.optfctx(x), opt_description.x0, [], obj.options );
            else
                [result.state, result.fval, result.counteval, ...
                result.stopflag, result.output, result.bestever ]...
                = Filter.Optimization.solver.cmaes(@(x) obj.optfctx(x), opt_description.x0, obj.sigma, obj.options );
                
            end
            result.record = obj.record;
            
        end
    end
end