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

config_models = [];
modelnames = Configurations.Optimization.Discrete.get_types();

%% add models
mname = modelnames.stcm;
config_models.(mname) = Configurations.Optimization.Discrete.(mname);
% config = Configurations.Optimization.Discrete.stcm;
config_models.(mname).name = 'P1';
filenames.(mname) = Optimization.Discrete.Models.(mname)(discretization, config_models.(mname));

%%% add models
mname = modelnames.mssqm;
config_models.(mname) = Configurations.Optimization.Discrete.(mname);
% config = Configurations.Optimization.Discrete.stcm;
config_models.(mname).name = 'P1';
filenames.(mname) = Optimization.Discrete.Models.(mname)(discretization, quality, config_models.(mname));

%%%
mname = modelnames.mspqm;
config_models.(mname) = Configurations.Optimization.Discrete.(mname);
% config = Configurations.Optimization.Discrete.stcm;
config_models.(mname).name = 'P1';
filenames.(mname) = Optimization.Discrete.Models.(mname)(discretization, quality, config_models.(mname));
%%%
mname = modelnames.bspqm;
config_models.(mname) = Configurations.Optimization.Discrete.(mname);
% config = Configurations.Optimization.Discrete.stcm;
config_models.(mname).name = 'P1';
filenames.(mname) = Optimization.Discrete.Models.(mname)(discretization, quality, config_models.(mname));

%%%
mname = modelnames.sco;
config_models.(mname) = Configurations.Optimization.Discrete.(mname);
% config = Configurations.Optimization.Discrete.stcm;
config_models.(mname).name = 'P1';
filenames.(mname) = Optimization.Discrete.Models.(mname)(discretization, quality, config_models.(mname));

%%%
mname = modelnames.gsco;
config_models.(mname) = Configurations.Optimization.Discrete.(mname);
% config = Configurations.Optimization.Discrete.stcm;
config_models.(mname).name = 'P1';
filenames.(mname) = Optimization.Discrete.Greedy.(mname)(discretization, quality, config_models.(mname));

%%%
mname = modelnames.gcs;
config_models.(mname) = Configurations.Optimization.Discrete.(mname);
% config = Configurations.Optimization.Discrete.stcm;
config_models.(mname).name = 'P1';
filenames.(mname) = Optimization.Discrete.Greedy.(mname)(discretization, quality, config_models.(mname));

%%%
mname = modelnames.gscs;
config_models.(mname) = Configurations.Optimization.Discrete.(mname);
% config = Configurations.Optimization.Discrete.stcm;
config_models.(mname).name = 'P1';
filenames.(mname) = Optimization.Discrete.Greedy.(mname)(discretization, quality, config_models.(mname));

%%%
mname = modelnames.gsss;
config_models.(mname) = Configurations.Optimization.Discrete.(mname);
% config = Configurations.Optimization.Discrete.stcm;
config_models.(mname).name = 'P1';
filenames.(mname) = Optimization.Discrete.Greedy.(mname)(discretization, quality, config_models.(mname));



%%
for filename = fieldnames(filenames)'
    disp(filenames.(filename{1}));
    fun_solve(filenames.(filename{1}));
end