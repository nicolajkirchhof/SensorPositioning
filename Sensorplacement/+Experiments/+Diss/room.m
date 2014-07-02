% function [processing] = room(num_wpn, num_sp)
%% calculates all evaluations for the given number of additional wpn and sp
clear variables functions
num_wpn = 100;
num_sp = 100;
name = 'P1';
workdir = sprintf('../tmp/p1/%dwpn_%dsp', num_wpn, num_sp);
if exist(workdir, 'dir')
    rmdir(workdir, 's');
end
filename = 'res\floorplans\P1-Seminarraum.dxf';
Configurations.Common.generic(name, workdir);


output_filename = sprintf('../tmp/p1/p1_%d_%d_%s.mat', num_wpn, num_sp, datestr(now,30));

cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe';
fun_solve = @(filename) Optimization.Discrete.Solver.cplex.run(filename, cplex);

%% Calculate input and greedy solutions

processing = Experiments.Diss.create_models(filename, num_wpn, num_sp, name);
save(output_filename, 'processing');

%% Solve models

modelfiles = fieldnames(processing.filenames);
for mfile = modelfiles'
    modelfile = mfile{1};
    if ischar(processing.filenames.(modelfile))
        processing.solutions.(modelfile) = fun_solve(processing.filenames.(modelfile));
    elseif isstruct(processing.filenames.(modelfile))
        for split_mfile = fieldnames(processing.filenames.(modelfile))'
            processing.solutions.(modelfile).(split_mfile{1}) = cellfun(fun_solve,  processing.filenames.(modelfile).(split_mfile{1}), 'uni', false);
        end
    end
    save(output_filename, 'processing');
end

