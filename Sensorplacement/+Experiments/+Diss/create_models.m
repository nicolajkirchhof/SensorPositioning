function [processing] = create_models(filename, num_wpn, num_sp, name)
%% [processing] = room(filename, num_wpn, num_sp, name) 
%   calculates the environment from filename with 
%   all evaluations for the given number of additional wpn and sp

% clear variables;
% format long;
if nargin < 4 
    error('All parameters have to be provided');
end

config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;

config_discretization.positions.additional = num_wpn;
config_discretization.sensorspace.poses.additional = num_sp;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality);

config_models = [];
modelnames = fieldnames(Configurations.Optimization.Discrete.get_types());

input.discretization = discretization;
input.environment = environment;
input.quality = quality;
% input.config.environment = config_environment;
input.config.discretization = config_discretization;
input.config.quality = config_quality;

%% Calculate Discrete Models
filenames = [];
solutions = [];
% logdata = [];
for mnamecell = modelnames'
    mname = mnamecell{1};
    if any(strcmp(mnamecell, {'generic', 'compare'}))
        continue;
    end
    config_models.(mname) = Configurations.Optimization.Discrete.(mname);
end
modelnames = fieldnames(config_models);
%%
for mnamecell = modelnames'
    mname = mnamecell{1};
    % config = Configurations.Optimization.Discrete.stcm;
    config_models.(mname).name = name;
    if strcmp(mname(1), 'g')
        solutions.(mname) = Optimization.Discrete.Greedy.(mname)(discretization, quality, config_models.(mname));
    else
        [filenames.(mname)] = Optimization.Discrete.Models.(mname)(discretization, quality, config_models.(mname));
%         solutions.(mname) = fun_solve(filenames.(mname));        
    end
end

%% Calculate Poly Decomp solutions
input.rpd.environment_collection = Environment.decompose(environment, Configurations.Environment.rpd);
input.hertel.environment_collection = Environment.decompose(environment, Configurations.Environment.hertel);
input.keil.environment_collection = Environment.decompose(environment, Configurations.Environment.keil);

%%
input.rpd.discretization_collection = Discretization.split(input.rpd.environment_collection, discretization);
input.hertel.discretization_collection = Discretization.split(input.hertel.environment_collection, discretization);
input.keil.discretization_collection = Discretization.split(input.keil.environment_collection, discretization);
%%
input.rpd.quality_collection = Quality.split(input.rpd.discretization_collection, quality);
input.hertel.quality_collection = Quality.split(input.hertel.discretization_collection, quality);
input.keil.quality_collection = Quality.split(input.keil.discretization_collection, quality);

%%

fun_bspqm = @(d, q) Optimization.Discrete.Models.bspqm(d, q, config_models.bspqm);
fun_mspqm = @(d, q) Optimization.Discrete.Models.bspqm(d, q, config_models.mspqm);

filenames.rpd.bspqm = cellfun(fun_bspqm, input.rpd.discretization_collection, input.rpd.quality_collection, 'uni', false);
filenames.hertel.bspqm = cellfun(fun_bspqm, input.hertel.discretization_collection, input.hertel.quality_collection, 'uni', false);
filenames.keil.bspqm = cellfun(fun_bspqm, input.keil.discretization_collection, input.keil.quality_collection, 'uni', false);

filenames.rpd.mspqm = cellfun(fun_mspqm, input.rpd.discretization_collection, input.rpd.quality_collection, 'uni', false);
filenames.hertel.mspqm = cellfun(fun_mspqm, input.hertel.discretization_collection, input.hertel.quality_collection, 'uni', false);
filenames.keil.mspqm = cellfun(fun_mspqm, input.keil.discretization_collection, input.keil.quality_collection, 'uni', false);


processing.input = input;
processing.filenames = filenames;
processing.solutions = solutions;

return;

%% TEST
num_wpn = 0;
num_sp = 0;
name = 'P1'
filename = 'res\floorplans\P1-Seminarraum.dxf';

[processing] = Experiments.Diss.create_models(filename, num_wpn, num_sp, name);



