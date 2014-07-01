function [ environment_collection ] = rpd( environment, debug )
%RPD uses the radial polygon decomposition to divide the input environment
% environment = Environment.combine(environment);
% pcomb = environment.combined{1};
%%
environment = Environment.combine(environment);
pcomb_simpl = Environment.Decompose.simplify(environment.combined{1}, 1);
[rings, cutinfo, pcd] = mb.polygonConvexDecomposition(pcomb_simpl);

environment_collection = {};

for idr = 1:numel(rings)
    environment_tmp = DataModels.environment();
    environment_tmp.boundary.ring = rings{idr};
    environment_tmp.boundary.isplaceable = ~cutinfo{idr};
    environment_tmp.file = [environment.file, '_' num2str(idr)];
    environment_collection{idr} = environment_tmp;
end


return;


%% Testing
clear variables;
format long;
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe';
fun_solve = @(filename) Optimization.Discrete.Solver.cplex.run(filename, cplex);
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);

environment_collection = Environment.Decompose.rpd(environment, true);

