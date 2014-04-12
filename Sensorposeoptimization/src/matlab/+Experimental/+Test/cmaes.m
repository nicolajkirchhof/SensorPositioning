%% CMAES TEST
function testCmaes()
stc = ThILo.Detail.Model.Sensor.StCartesian;
stc.Position = [0 0 0];
stc.Orientation = [0 0 Mltools.deg2rad(22.5)];
stc.StateIdx = [1 2];
m = stc.evaluate([2; 1]);



Filter.Optimization.solver.cmaes('Experimental.Test.cmaesTestFitfunc', [1.7; 0.7], 1, [], stc, m);

end

