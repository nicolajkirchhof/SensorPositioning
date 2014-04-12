scal = syscal.loadTestCase(['tc' num2str(1)]);

syscal.plotState(scal);
scal.state_error = @(x) sum(x.^2);

syscal.addStateNoiseUni(scal);
h = syscal.plotState(scal);

scal.userData.plotHandle = h;
scal.userData.plotState = true;

fun = @(x) syscal.calcStateAoaTan(x, scal);

opt = optimset('display', 'iter'...
  , 'maxfunevals', 2000*numel(scal.stateCurrent) ...
  , 'maxiter', 2000*numel(scal.stateCurrent) ...
    , 'plotfcns', @optimplotfval... 
    , 'tolfun', 1e-8...
    , 'tolx', 1e-8...
...    , 'Algorithm', 'active-set'...
    , 'Jacobian', 'on'...
..., 'Algorithm', 'sqp'...
    );

P.objective = fun;
P.x0 = scal.stateCurrent;
P.options = opt;
P.solver = 'lsqnonlin';

[state, fval, exitflag, output ] = lsqnonlin(P);
