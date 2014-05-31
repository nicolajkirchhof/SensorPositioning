%% testing cplex sos

c = Cplex('sostest');
%%
num_var = 9;
num_s = 6;
num_w = 3;
c.Model.A = [ones(1,num_s) zeros(1,num_w); % default choose 2 sensors
    0 1 1 1 0 0 zeros(1,num_w); % sameplace
];
c.Model.lhs = [2 0 ]';
c.Model.rhs = [inf 1 ]';
c.Model.ctype = [repmat('B', 1, 6),'CCC'];
c.Model.obj = [ones(3,1); zeros(3,1); ones(3,1)];
c.Model.lb = [zeros(6,1); -inf(3,1)];
c.Model.ub = [ones(6,1); inf(3,1)];
% c.addSOSs('1', [1 2]', [1 1]', {'s1'});
c.solve();
c.Solution.x
