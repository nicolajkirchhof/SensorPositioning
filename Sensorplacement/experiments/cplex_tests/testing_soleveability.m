%% testing cplex sos

c = Cplex('sostest');
%%
num_var = 9;
c.Model.A = [
     1  1 1 0 0 0 0 0 0;
     1  0 1 0 0 0 0 0 0; 
     1  1 0 -1 0 0 0 0 0;
     1  0 1 0 -1 0 0 0 0;
     0  1 1 0 0 -1 0 0 0;
    -1  0 0 1 0 0 0 0 0;
     0 -1 0 1 0 0 0 0 0;
    -1  0 0 0 1 0 0 0 0;
     0  0 -1 0 1 0 0 0 0;
     0  0 -1 0 0 1 0 0 0;
     0 -1 0 0 0 1 0 0 0;
     0  0  0  .1   0   0  -1  0  0;
     0  0  0  -1  .5   0  -1  0  0;
     0  0  0  -1  -1  .6  -1  0  0;
     0  0  0  .9  -1  -1    0 -1  0;
     0  0  0   0  .1   0    0 -1  0;
     0  0  0   0  -1  .8    0 -1  0;
     0  0  0  .8  -1  -1     0  0 -1;
     0  0  0   0  .8  -1     0  0 -1;
     0  0  0   0   0  .1    0  0 -1;
    ];
c.Model.lhs = [2 0 -inf(1,9) -inf(1,9) ]';
c.Model.rhs = [inf 1 1 1 1 zeros(1,6) zeros(1,9)]';
c.Model.ctype = [repmat('B', 1, 6),'CCC'];
c.Model.obj = [ones(3,1); zeros(3,1); ones(3,1)];
c.Model.lb = [zeros(6,1); -inf(3,1)];
c.Model.ub = [ones(6,1); inf(3,1)];
% c.addSOSs('1', [1 2]', [1 1]', {'s1'});
c.solve();
c.Solution.x