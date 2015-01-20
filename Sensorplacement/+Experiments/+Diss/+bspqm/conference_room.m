% function [processing] = room(num_wpn, num_sp)
%%

%%
close all;
% num_sp = 0:20:200
num_wpns = 0:10:50;
num_sps = 60:10:100;
bspqm = cell(numel(num_wpns), numel(num_sps));
for id_wpn = 1:numel(num_wpns)
    for id_sp = 1:numel(num_sps)
        num_wpn = num_wpns(id_wpn);
        num_sp = num_sps(id_sp);
        
        %%
        num_wpn = 0;
        num_sp = 0;
        
        input = Experiments.Diss.conference_room(num_sp, num_wpn, true);
        %%
        output_filename = sprintf('tmp/conference_room/bspqm__%d_%d_%d.mat', discretization.num_sensors, discretization.num_positions, discretization.num_comb);
        input.filename = Optimization.Discrete.Models.bspqm(input.discretization, quality, Configurations.Optimization.Discrete.bspqm);
        save(output_filename);
    end
end
% % Calculate Discrete Models
%mspqm = Optimization.Discrete.Models.mspqm(discretization, quality, Configurations.Optimization.Discrete.mspqm);
% sol = Optimization.Discrete.Solver.cplex.read_solution('tmp/conference_room/bspqm__130_20_5172.sol');
% log = Optimization.Discrete.Solver.cplex.read_log('tmp/conference_room/bspqm__130_20_5172.log');

%%
for mnamecell = modelnames'
    mname = mnamecell{1};
    % config = Configurations.Optimization.Discrete.stcm;
    config_models.(mname).name = name;
    if strcmp(mname(1), 'g')
        %         solutions.(mname) = Optimization.Discrete.Greedy.(mname)(discretization, quality, config_models.(mname));
    else
        [filenames.(mname)] = Optimization.Discrete.Models.(mname)(discretization, quality, config_models.(mname));
        %         solutions.(mname) = fun_solve(filenames.(mname));
    end
end

% %% Calculate Poly Decomp solutions
% input.rpd.environment_collection = Environment.decompose(environment, Configurations.Environment.rpd);
% input.hertel.environment_collection = Environment.decompose(environment, Configurations.Environment.hertel);
% input.keil.environment_collection = Environment.decompose(environment, Configurations.Environment.keil);
%
% %%
% input.rpd.discretization_collection = Discretization.split(input.rpd.environment_collection, discretization);
% input.hertel.discretization_collection = Discretization.split(input.hertel.environment_collection, discretization);
% input.keil.discretization_collection = Discretization.split(input.keil.environment_collection, discretization);
% %%
% input.rpd.quality_collection = Quality.split(input.rpd.discretization_collection, quality);
% input.hertel.quality_collection = Quality.split(input.hertel.discretization_collection, quality);
% input.keil.quality_collection = Quality.split(input.keil.discretization_collection, quality);
%
% %%
%
% fun_bspqm = @(d, q) Optimization.Discrete.Models.bspqm(d, q, config_models.bspqm);
% fun_mspqm = @(d, q) Optimization.Discrete.Models.bspqm(d, q, config_models.mspqm);
%
% filenames.rpd.bspqm = cellfun(fun_bspqm, input.rpd.discretization_collection, input.rpd.quality_collection, 'uni', false);
% filenames.hertel.bspqm = cellfun(fun_bspqm, input.hertel.discretization_collection, input.hertel.quality_collection, 'uni', false);
% filenames.keil.bspqm = cellfun(fun_bspqm, input.keil.discretization_collection, input.keil.quality_collection, 'uni', false);
%
% filenames.rpd.mspqm = cellfun(fun_mspqm, input.rpd.discretization_collection, input.rpd.quality_collection, 'uni', false);
% filenames.hertel.mspqm = cellfun(fun_mspqm, input.hertel.discretization_collection, input.hertel.quality_collection, 'uni', false);
% filenames.keil.mspqm = cellfun(fun_mspqm, input.keil.discretization_collection, input.keil.quality_collection, 'uni', false);
%
%
processing.input = input;
processing.filenames = filenames;
processing.solutions = solutions;
%
return;

%% TEST
num_wpn = 0;
num_sp = 0;
name = 'P1'
filename = 'res\floorplans\P1-Seminarraum.dxf';

[processing] = Experiments.Diss.create_models(filename, num_wpn, num_sp, name);





%     end
% end

%% Solve models

% modelfiles = fieldnames(processing.filenames);
% % modelfiles = {'tekdas'};
% for mfile = modelfiles'
%     modelfile = mfile{1};
%     if ischar(processing.filenames.(modelfile))
%         processing.solutions.(modelfile) = fun_solve(processing.filenames.(modelfile));
%     elseif isstruct(processing.filenames.(modelfile))
%         for split_mfile = fieldnames(processing.filenames.(modelfile))'
%             processing.solutions.(modelfile).(split_mfile{1}) = cellfun(fun_solve,  processing.filenames.(modelfile).(split_mfile{1}), 'uni', false);
%         end
%     end
%     save(output_filename, 'processing');
% end
% return;
%%
% Experiments.Diss.room
