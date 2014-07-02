function [ environment_collection ] = decompose( environment, config, debug )
%RPD uses the radial polygon decomposition to divide the input environment
% environment = Environment.combine(environment);
% pcomb = environment.combined{1};
%%
environment = Environment.combine(environment);
pcomb_simpl = Environment.simplify(environment.combined{1}, 1);

types = Configurations.Environment.get_types();
cutinfo = [];
switch config.type
    case types.rpd
        [rings, cutinfo, pcd] = mb.polygonConvexDecomposition(pcomb_simpl);
    case types.hertel
        rings = polypartition(pcomb_simpl, 3);
    case types.keil
        rings = polypartition(pcomb_simpl, 4);
end

environment_collection = {};

for idr = 1:numel(rings)
    environment_tmp = DataModels.environment();
    environment_tmp.boundary.ring = rings{idr};
    if ~isempty(cutinfo)
    environment_tmp.boundary.isplaceable = ~cutinfo{idr};
    end
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

config = Configurations.Environment.rpd;
environment_collection = Environment.decompose(environment, config, true);

config = Configurations.Environment.hertel;
environment_collection2 = Environment.decompose(environment, config, true);

config = Configurations.Environment.keil;
environment_collection3 = Environment.decompose(environment, config, true);

