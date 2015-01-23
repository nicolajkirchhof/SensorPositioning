function [solfile, logfile] = start(filename, cplex)

if nargin < 2
    cplex = 'cplex.exe';
end
solfile = [filename(1:end-2) 'sol'];
logfile = [filename(1:end-2) 'log'];
if exist(solfile, 'file')
    delete(solfile);
end
if exist(logfile, 'file')
    delete(logfile);
end

cpx_read = sprintf('"read %s"', filename);
cpx_log = sprintf('"set logfile %s"', logfile);
% cpx_workdir = sprintf('"set workdir %s"', workdir);
cpx_start = '"optimize"';
cpx_write = sprintf('"write %s"', solfile);

cmd = sprintf('%s -c %s %s %s %s "quit"', cplex, cpx_read, cpx_log, cpx_start, cpx_write);
%%%
% cmd = sprintf('CplexMIPOpt.exe --workdir d:%stmp --input-file %s --threads 3 --workmem 1000 --node-file 3 --tree-limit 3e3', filesep, filename);
system(cmd, '-echo');
fprintf(1, '\n');

return;

%% TEST
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality); 

config = Configurations.Optimization.Discrete.stcm;
config.name = 'P1';
filename = Optimization.Discrete.Models.stcm(discretization, [], config);
%%%
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
[solution] = Optimization.Discrete.Solver.cplex.start(filename, cplex);

