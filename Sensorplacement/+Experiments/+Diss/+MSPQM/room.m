clear variables;
format long;
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
fun_solve = @(filename) Optimization.Discrete.Solver.cplex.startext(filename, cplex);
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

filenames = [];
solutions = [];

config_models = [];
modelnames = Configurations.Optimization.Discrete.get_types();

%% add models

for mnamecell = fieldnames(modelnames)'
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
        filenames.(mname) = Optimization.Discrete.Models.(mname)(discretization, quality, config_models.(mname));
    end
end


%%
for filename = fieldnames(filenames)'
    disp(filenames.(filename{1}));
    fun_solve(filenames.(filename{1}));
end