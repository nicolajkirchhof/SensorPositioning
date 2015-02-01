function [input] = small_flat(num_sp, num_wpn)
%%
% clear variables;% functions;

if nargin < 3
    draw = false;
end
%%
% num_sp = 0;
% num_wpn = 0;

name = 'SmallFlat';


lookupdir = sprintf('tmp/small_flat/discretization');

env = load('tmp\small_flat\environment\environment.mat');
environment = env.environment;

lookup_filename = [lookupdir filesep sprintf('%d_%d.mat', num_sp, num_wpn)];
%%
if ~exist(lookup_filename, 'file')
       
    %%
%             num_sp =  0;
%             num_wpn = 0;
    config_discretization = Configurations.Discretization.iterative;
    config_discretization.workspace.wall_distance = 200;
    % config_discretization.workspace.cell.length = [0 1000];
    config_discretization.workspace.positions.additional = num_wpn;
    config_discretization.sensorspace.poses.additional = num_sp;
    config_discretization.common.verbose = 0;
    discretization = Discretization.generate(environment, config_discretization);
    
    %%%
    config_quality = Configurations.Quality.diss;
    [quality] = Quality.generate(discretization, config_quality);
    
    input.discretization = discretization;
    input.quality = quality;
    %         input.config.environment = config_environment;
    input.config.discretization = config_discretization;
    input.config.quality = config_quality;
    input.timestamp = datestr(now,30);
    input.name = name;
    
%     input.environment = environment;
% Experiments.Diss.draw_input(input)
    %%
    save(lookup_filename, 'input');
   
    input.environment = environment;
else
    
    input = load(lookup_filename);
    input = input.input;
    input.environment = environment;
end

return;
%%
input.environment = environment;
Experiments.Diss.draw_input(input)

%%
num_wpns = 0:10:500;
num_sps =  0:10:500;
iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps);
write_log([], '#off');

for id_wpn = 1:numel(num_wpns)
    for id_sp = 1:numel(num_sps)
        num_wpn = num_wpns(id_wpn);
        num_sp = num_sps(id_sp);
        
        %%
%         num_wpn = 10;
%         num_sp = 10;
        
        Experiments.Diss.small_flat(num_sp, num_wpn);

        %%
        iteration = iteration + 1;
        if toc(tme)>next
            fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
            next = toc(tme)+stp;
        end
    end
end


