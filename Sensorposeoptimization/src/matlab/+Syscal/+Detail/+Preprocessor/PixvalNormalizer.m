classdef PixvalNormalizer
    
    properties
        preprocessors
        aoaextractors
    end
    
    
    methods
        function [ aoas, pixel_values_normalized, position_estimates ] = apply( obj, pixel_values,  measure_referernce )
            %NORMALIZEPIXVALS Summary of this function goes here
            %   Detailed explanation goes here
            
            pixel_values_normalized = {};
            aoas = {};
            for idx_sensor = 1:size(pixel_values, 1)
                for idx_measure = 1:size(pixel_values, 2)
                    for j = 1:130,
                        norm_pixval = obj.preprocessors{idx_sensor}.apply(pixel_values{idx_sensor,idx_measure}');
                    end
                    if ~isempty(norm_pixval)
                        [aoa, pos] = obj.aoaextractors{idx_sensor}.apply(norm_pixval, measure_referernce(idx_measure,:));
                        aoas{idx_sensor, idx_measure} = aoa;
                        position_estimates{idx_sensor, idx_measure} = pos;
                        pixel_values_normalized{idx_sensor, idx_measure} = norm_pixval;
                    end
                end
            end
        end
    end
end