xv = [-1 -1 1 1]';
yv = [-1 1 1 -1]';
x=linspace(-2,2,11)';
y=linspace(-2,2,11)';
%%%
% [x y]=meshgrid(x,y);
% in = insidepoly_dblengine(x, y, xv, yv, 1e-6);
in2 = insidepoly_nico(x, y, xv, yv, 1e-6, 1);