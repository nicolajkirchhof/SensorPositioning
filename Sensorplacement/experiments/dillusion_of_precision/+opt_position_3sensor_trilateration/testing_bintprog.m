num_sensors = 4;
num_points = 5;

BSP = [ 1 1 1 0 1;...
        1 1 0 1 1;...
        1 0 1 1 1;...
        0 1 1 1 1];
f = ones(num_sensors, 1);
b = -2*ones(1, num_points);
A = -1*BSP';


[x, fval, exitflag, output] = bintprog(f, A, b);
[xcplex, fvalcplex, exitflagcplex, outputcplex] = cplexbilp(f, A, b);