% function [processing] = room(num_wpn, num_sp)
%% calculates all evaluations for the given number of additional wpn and sp

% num_wpn = 100;
% num_sp = 100;
clear variables functions
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe';
fun_solve = @(filename) Optimization.Discrete.Solver.cplex.run(filename, cplex);
%%
for num_wpn = 150:50:200
    for num_sp = 0:50:200
        %%
        
clear functions
%%
%  num_wpn = 0;
%         num_sp = 0;
name = 'SmallFlat';
workdir = sprintf('../tmp/%s/%dwpn_%dsp',name,  num_wpn, num_sp);
if exist(workdir, 'dir')
    rmdir(workdir, 's');
end
filename = 'res\floorplans\SmallFlat.dxf';
Configurations.Common.generic(name, workdir);

output_filename = sprintf('../tmp/smallflat/smallflat_%d_%d_%s.mat', num_wpn, num_sp, datestr(now,30));

%%% Calculate input and greedy solutions

processing = Experiments.Diss.create_models(filename, num_wpn, num_sp, name);
save(output_filename, 'processing');
    end
end
return;
%% Solve models

modelfiles = fieldnames(processing.filenames);
% modelfiles = {'tekdas'};
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
return;
%%
Experiments.Diss.room 
