%% init
p = fileparts(mfilename('fullpath'));
dbstop if error

%% load libs
% run extensions.matlab/lib/ext_all.m
addpath([p filesep 'src']);
addpath([p filesep 'experiments']);

libs.add_all;
% addpath example/matlab/
% addpath 

%% fix for zeus
% set(0, 'DefaultFigurePosition', get(0, 'FactoryFigurePosition'))
% cplxdir1 = [getenv('home') '\App\cplex\cplex\matlab\x64_win64'];
% cplxdir2 = '~/opt/ibm/ILOG/CPLEX_Studio124/cplex/matlab/';

% if exist(cplxdir1, 'dir')
    % addpath(cplxdir1);
    % addpath([getenv('home') '\App\Cplex\cplex\examples\src\matlab']);
    % addpath([getenv('home') '\App\cplex\cplex\matlab\x64_win64\help']);
% elseif exist(cplxdir2, 'dir')
    % addpath(cplxdir2);
% end

% clear cplxdir1 cplxdir2 p
