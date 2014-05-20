function [vals, ids] = findtwocrossings(M, val)

M(M>=val) = 0;
[Mmax, Mmaxid] = max(diff(M));
[Mmin, Mminid] = min(diff(M));

ids = [Mmaxid;Mminid];
vals = [Mmax;-Mmin];

flt = vals < 0.9*val;
ids(flt) = nan;
vals(flt) = nan;



