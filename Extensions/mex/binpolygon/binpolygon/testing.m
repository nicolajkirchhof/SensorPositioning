px = [1 2 3 2.5 3 3.5 3.5];
py = [1 2 2 1.5 1.5 2 1];
plot(px, py);
x = [2.74 2.76];
y = [1.75 1.75];
%%
[in on] = insidepoly_nico(x', y', px', py', 1e-6)
%%
[in on] = insidepoly_orig(x, y, px, py, 'tol', 1e-6)
%%