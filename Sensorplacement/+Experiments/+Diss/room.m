clear variables;
format long;
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

%%
filenames = [];
solutions = [];
logdata = [];
for mnamecell = modelnames'
    mname = mnamecell{1};
    if any(strcmp(mnamecell, {'generic', 'compare'}))
        continue;
    end
    
    config_models.(mname) = Configurations.Optimization.Discrete.(mname);
    % config = Configurations.Optimization.Discrete.stcm;
    config_models.(mname).name = 'P1';
    if strcmp(mname(1), 'g')
        solutions.(mname) = Optimization.Discrete.Greedy.(mname)(discretization, quality, config_models.(mname));
    else
        [filenames.(mname)] = Optimization.Discrete.Models.(mname)(discretization, quality, config_models.(mname));
        solutions.(mname) = fun_solve(filenames.(mname));        
    end
end

%%
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
