function [processing] = room(num_wpn, num_sp)
%% calculates all evaluations for the given number of additional wpn and sp

% clear variables;
% format long;
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe';
fun_solve = @(filename) Optimization.Discrete.Solver.cplex.run(filename, cplex);
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
    config_models.(mname).name = 'P1';
    if strcmp(mname(1), 'g')
        solutions.(mname) = Optimization.Discrete.Greedy.(mname)(discretization, quality, config_models.(mname));
    else
        [filenames.(mname)] = Optimization.Discrete.Models.(mname)(discretization, quality, config_models.(mname));
        solutions.(mname) = fun_solve(filenames.(mname));        
    end
end

%% Plot discrete Models
figure;
num_subpolots = numel(modelnames);
num_lines = 2;
num_per_line = ceil((num_subpolots-2)/num_lines);
subplots_layout = {num_lines, num_per_line};
subplots_id = 1;

for mnamecell = modelnames'
    mname = mnamecell{1};
    if any(strcmp(mnamecell, {'generic', 'compare'}))
        continue;
    end
    
    subplot(subplots_layout{:}, subplots_id);
    Environment.draw(environment, false); hold on;
    Discretization.Workspace.draw(discretization.wpn);
%     solutions.(mname).selected_sensors = find(solutions.(mname).x(1:discretization.num_sensors));
    Evaluation.draw.pose(discretization.sp(:, solutions.(mname).sensors_selected), 1000);
    mb.drawPolygon(discretization.vfovs(solutions.(mname).sensors_selected));
    title(sprintf('%s s=%d', mname, numel(solutions.(mname).sensors_selected)));
    subplots_id = subplots_id + 1;
end

%% Calculate Poly Decomp solutions
rpd_env_collection = Environment.decompose(environment, Configurations.Environment.rpd);
hertel_env_collection = Environment.decompose(environment, Configurations.Environment.hertel);
keil_env_collection = Environment.decompose(environment, Configurations.Environment.keil);

%%
rpd_dis_collection = Discretization.split(rpd_env_collection, discretization);
hertel_dis_collection = Discretization.split(hertel_env_collection, discretization);
keil_dis_collection = Discretization.split(keil_env_collection, discretization);
%%
rpd_qual_collection = Quality.split(rpd_dis_collection, quality);
hertel_qual_collection = Quality.split(hertel_dis_collection, quality);
keil_qual_collection = Quality.split(keil_dis_collection, quality);

%%
fun_bspqm = @(d, q) Optimization.Discrete.Models.bspqm(d, q, config_models.bspqm);
filenames.rdp.bspqm = cellfun(fun_bspqm, rdp_dis_collection, rdp_qual_collection, 'uni', false);
    
%         discretization = discretization_collection{id_dis};
%         quality = quality_collection{id_dis};
%         filenames = Optimization.Discrete.Models.bspqm(discretization, quality, config_models);
%         solutions{id_dis} = fun_solve(filenames{id_dis}); 


%% Other Partitions


config = Configurations.Environment.hertel;
environment_collection2 = Environment.Decompose.rpd(environment, config, true);

config = Configurations.Environment.keil;
environment_collection3 = Environment.Decompose.rpd(environment, config, true);



