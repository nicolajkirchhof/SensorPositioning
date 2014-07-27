function [ pcomb_simp ] = simplify( pcomb, debug )
%RPD uses the radial polygon decomposition to divide the input environment
% environment = Environment.combine(environment);
% pcomb = environment.combined{1};
%%
if nargin < 2
    debug = false;
end

if debug
cla
mb.drawPolygon(pcomb, 'color', 'g', 'marker', 'x');
end

fun_simplify = @(ring) int64(dpsimplify.dpsimplify(double(ring'), 50)');

pcomb_it1 = cellfun(fun_simplify , pcomb, 'uni', false);
pcomb_simp = pcomb;
%%
while ~all(cellfun(@(p1, p2) all(size(p1)==size(p2)), pcomb_it1, pcomb_simp))
    %%
    pcomb_it1 = pcomb_simp;
    pcomb_rot = cellfun(@(ring) [ring(:,2), circshift(ring(:,2:end), -1, 2)], pcomb_it1, 'uni', false);
    pcomb_simp = cellfun(fun_simplify, pcomb_rot, 'uni', false);
end

if debug
mb.drawPolygon(pcomb_simp, 'color', 'r', 'marker', 'o');
end


return;

%% TESTING
clear variables;
format long;
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe';
fun_solve = @(filename) Optimization.Discrete.Solver.cplex.run(filename, cplex);
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
environment = Environment.combine(environment);
pcomb_simpl = Environment.Decompose.simplify(environment.combined{1}, 1);
