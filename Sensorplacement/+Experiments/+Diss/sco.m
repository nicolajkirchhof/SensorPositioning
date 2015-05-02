%%
close all;
clear variables;
% num_sp = 0:20:200
% num_wpns = 0:10:50;
% num_wpns = 0:10:490;
num_wpns = 0:10:500;
num_sps =  0:10:500;
cplex = [getenv('home') '\App\Cplex\cplex\bin\x64_win64\cplex.exe'];

% names = {'conference_room'} %,  % 'large_flat', 'office_floor'};
names = {'small_flat'}
% names = {'large_flat', 'office_floor'};
% names = {'office_floor'}
% names = {'conference_room'};

iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps)*numel(names);

% write_log([], '#off');

for id_n = 1:numel(names)
%     sco = cell(numel(num_sps), numel(num_wpns));
    name = names{id_n};
    for id_wpn = 1:numel(num_wpns)
        for id_sp = 1:numel(num_sps)
            num_wpn = num_wpns(id_wpn);
            num_sp = num_sps(id_sp);
           
            filename = sprintf('tmp/%s/sco/sco_%s_%d_%d_.sol', name, name, num_sp, num_wpn);
            
            if exist(filename, 'file') == 0
            input = Experiments.Diss.(name)(num_sp, num_wpn);
            input.config.optimization.name = input.name;
            gen = Configurations.Common.generic();
            gen.workdir = sprintf('tmp/%s/sco', name);
            stcm_config = Configurations.Optimization.Discrete.sco(gen);
            stcm_config.name = name;
            problemfile = Optimization.Discrete.Models.sco(input.discretization, input.quality, stcm_config);
            %%
            [solutionfile, logfile] = Optimization.Discrete.Solver.cplex.start(problemfile, cplex, true);
            
            %%
            end
        end
    end
end


return;
