function [ log ] = read_log( logfile, log )
%READ_LOG Summary of this function goes here
%   Detailed explanation goes here

% get full path
% [path, base] = fileparts(problemfile);
% if ~isempty(strtrim(path))
%     addpath(path);
% end
% problemfile = which(problemfile);
%  logfile = [path filesep base '.cplog'];
if ~exist(logfile, 'file')
    warning('log to file %s does not exist', problemfile);
    return;
end
%%
if nargin < 2
    log = DataModels.optimizationlog();
end
[q,w] = system(['tail -n ',num2str(50),' ',logfile]);

%%
flog = fopen(logfile);
slne = fgetl(flog);
slne_1 = slne;
slne = fgetl(flog);
last_table_line = [];
%% find gap
id_last_pct = find(w == '%', 1, 'last');
log.gap = sscanf(w(id_last_pct-5:id_last_pct), '%g');

ws_cleaned_string = sscanf(w(id_last_pct+1:end), '%s');
% )Solutiontime=0.11sec.Iterations=721Nodes=0(1)Deterministictime=71.58ticks(656.71ticks/sec)Incumbentsolutionwrittentofile'../tmp/bspqm/bspqm_P1_42_14_527.sol'.
%%
str_tst = 'Solutionpool:';
id_start = strfind(ws_cleaned_string, str_tst);
log.num_solutions = sscanf(ws_cleaned_string(id_start+length(str_tst):end), '%dsolutions%*s');

str_tst = 'Solutiontime=';
id_start = strfind(ws_cleaned_string, str_tst);
log.solutiontime = sscanf(ws_cleaned_string(id_start+length(str_tst):end), '%gsec%*s');

str_tst = 'Deterministictime=';
id_start = strfind(ws_cleaned_string, str_tst);
log.deterministictime = sscanf(ws_cleaned_string(id_start+length(str_tst):end), '%gticks%*s');

str_tst = 'ticks(';
id_start = strfind(ws_cleaned_string, str_tst);
log.tickspersec = sscanf(ws_cleaned_string(id_start+length(str_tst):end), '%gticks%*s');


fclose(flog);



return;

%% TEST
clear variables;
format long;
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

%%
config = Configurations.Optimization.Discrete.bspqm;
config.name = 'P1';
filename = Optimization.Discrete.Models.bspqm(discretization, quality, config);
%%%
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
[solfile, logfile] = Optimization.Discrete.Solver.cplex.start(filename, cplex);
%%
log = Optimization.Discrete.Solver.cplex.read_log(logfile)
edit(logfile);

%%

config = Configurations.Optimization.Discrete.stcm;
config.name = 'P1';
filename = Optimization.Discrete.Models.stcm(discretization, [], config);
%%%
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
[solfile2, logfile2] = Optimization.Discrete.Solver.cplex.start(filename, cplex);
log = Optimization.Discrete.Solver.cplex.read_log(logfile2)
edit(logfile2);



%% OLD CODE

% while ischar(slne) 
%     if ~isempty(strfind(slne, '%'))
%         last_table_line = slne;
%     end
%     slne = fgetl(flog);
% end

%%
% while isempty(strfind(slne, 'Solution time')) && ischar(slne)
%     slne_1 = slne;
%     slne = fgetl(flog);
% end
% 
% %%
% log = DataModels.optimizationlog();
% dbl_slne_1 = double(slne_1);
% fun_flt_num = @(dstr) (dstr >=48 & dstr <=57) | dstr == 46;
% flt_num = fun_flt_num(dbl_slne_1);
% values = {};
% %% extract values
% while any(flt_num)
%     %%
%     id_start = find(flt_num, 1, 'first');
%     id_end = id_start + 1;
%     while flt_num(id_end)
%         id_end = id_end + 1;
%     end
%     id_end = id_end - 1;
%     values{end+1} = str2num(slne_1(id_start:id_end));
%     flt_num(id_start:id_end) = 0;
% end
% 
% log.node = values{1};
% log.left = values{2};
% log.iinf = values{3};
% log.bestinteger = values{4};
% log.bestbound = values{5};
% log.itcnt = values{6};
% log.gap = values{7};
% 
% stmp = char(sscanf(slne, '%s'));
% 
% [sscanf_vals] = sscanf(stmp, 'Elapsedtime=%gsec.(%gticks,tree=%gMB,solutions=%d)');
% log.elapsedtime = sscanf_vals(1);
% log.ticks = sscanf_vals(2);
% log.tree = sscanf_vals(3);
% log.solutions = sscanf_vals(4);
% 
%%
% while isempty(strfind(slne, 'Nodes')) && ischar(slne)
%     slne = fgetl(flog);
% end
% %%
% num_table_entries = 100;
% log.table = cell(1,num_table_entries);
% %         sol.table{end+1} = slne;
% idts = (1:num_table_entries)';
% while isempty(strfind(slne, 'Root node processing')) && ischar(slne)
%     slne = fgetl(flog);
%     idt = idts(1);
%     log.table{idt} = slne;
%     idts = circshift(idts, -1);
% end
%% find last log properties
% idt = num_table_entries-1;
% stmp = char(sscanf(log.table{idts(idt)}, '%s'));
% while idt > 0 && (isempty(stmp) || strcmp(stmp(1), '*') == 0)
%     stmp = char(sscanf(log.table{idts(idt)}, '%s'));
%     idt = idt - 1;
% end
% if idt > 0
%     sbest = log.table{idts(idt+1)};
%     [tbest, rest] = strtok(sbest, ' ');
%     [tnode, rest] = strtok(strtrim(rest), ' ');
%     % skip the next 20 char
%     num_skip = numel('     Objective  IInf');
%     rest = rest(num_skip+1:end);
%     [tbestint, rest] = strtok(strtrim(rest), ' ');
%     [tbestbound, rest] = strtok(strtrim(rest), ' ');
%     [titcnt, rest] = strtok(strtrim(rest), ' ');
%     [tgap, rest] = strtok(strtrim(rest), '%');
%
%     %             sol.best = num2str(tbest);
%     log.node = num2str(tnode);
%     log.bestint = num2str(tbestint);
%     log.bestbound = num2str(tbestbound);
%     log.itcnt = num2str(titcnt);
%     log.gap = num2str(tgap);
% end
%%
% slne = fgetl(flog);
% stmp = char(sscanf(slne, '%s'));
% [rt] = sscanf(stmp, 'Realtime=%fsec.(%fticks)');
% log.rtbeforebc_sec = rt(1);
% log.rtbeforebc_ticks = rt(2);
% slne = fgetl(flog);
% stmp = char(sscanf(slne, '%s'));
% log.threads = sscanf(stmp, 'Parallelb&c,%dthreads:');
% slne = fgetl(flog);
% stmp = char(sscanf(slne, '%s'));
% [rt] = sscanf(stmp, 'Realtime=%gsec.(%gticks)');
% log.rtbc_sec = rt(1);
% log.rtbc_ticks = rt(2);
% slne = fgetl(flog);
% stmp = char(sscanf(slne, '%s'));
% log.synctime = sscanf(stmp, 'Synctime(average)=%fsec.');
% slne = fgetl(flog);
% stmp = char(sscanf(slne, '%s'));
% log.waittime = sscanf(stmp, 'Waittime(average)=%fsec.');
% fgetl(flog);
% slne = fgetl(flog);
% stmp = char(sscanf(slne, '%s'));
% [tt]  = sscanf(stmp, 'Total(root+branch&cut)=%f sec.(%f ticks)');
% log.total_sec = tt(1);
% log.total_ticks = tt(2);
% fclose(flog);