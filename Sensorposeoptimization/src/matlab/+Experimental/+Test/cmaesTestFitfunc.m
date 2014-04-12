function prob = cmaesTestFitfunc(x, stc, m)
    prob = 1 - stc.likelihood(m, x);
end
