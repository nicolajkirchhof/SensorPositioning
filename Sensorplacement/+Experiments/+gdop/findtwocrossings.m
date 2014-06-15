function [vals, ids] = findtwocrossings(M, val)
%% findtwocrossings(M, val) calculates the intersections of two functions
% 

M(M>=val) = 0;
[Mmax, Mmaxid] = max(diff(M));
[Mmin, Mminid] = min(diff(M));

ids = [Mmaxid;Mminid];
vals = [Mmax;-Mmin];

flt = vals < 0.9*val;
ids(flt) = nan;
vals(flt) = nan;



