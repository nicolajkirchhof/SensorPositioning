function [in_circ, out_circ] = calc_uncertaintyCircles(uc, t, s)
    in_circ = [s distance_calc(t, s)-uc];
    out_circ = [s distance_calc(t, s)+uc];
    
    function d = distance_calc(t, s)
        d = sum((t-s).^2).^0.5;
