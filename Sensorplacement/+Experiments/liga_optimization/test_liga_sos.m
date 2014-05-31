%% 
clear c;
c = Cplex('sostest');
%%%
num_var = 4;
c.Model.A = [
    1 1 1 1;
%     0 0 1 1 1 0 0 0 0; 
%     1 1 0 0 0 1 1 1 1;
%     0 0 1 1 1 0 0 0 0;
    ];
c.Model.lhs = [2 ]';
c.Model.rhs = [2 ]';
c.Model.ctype = [repmat('B', 1, num_var)];
c.Model.obj = [1 2 3 2]';
c.Model.lb = [zeros(num_var,1);];
c.Model.ub = [ones(num_var,1);];
c.addSOSs('1', [1 2 ]', [1 2 ]', {'s1'});
c.addSOSs('1', [3 4]', [3 5 ]', {'s2'});
% c.addSOSs('1', [2 3]', [6 4]', {'s1'});
c.addSOSs('1', [1 4]', [1 2]', {'s1'});
% c.addSOSs('1', [2 4]', [10 6]', {'s1'});
c.solve();
% c.Solution.x