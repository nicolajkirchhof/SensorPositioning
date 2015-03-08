%%
num_sp = 0;
num_wpn = 0;
name = 'small_flat';
input = Experiments.Diss.small_flat(num_sp, num_wpn);
%%
[P_c, E_r] = mb.polygonConvexDecomposition(input.environment.combined);


P_c = cellfun(@(x) mb.visilibity2boost(x), P_c, 'uniformoutput', false);
%%
clearvars;
load tmp\small_flat\environment\environment.mat
lookupdir = 'tmp/small_flat/discretization/';

files = dir([lookupdir '*.mat']);

%%
% loop_display(numel(files), 5);
cnt = 0;
for idf = 1:numel(files)
    filename = [lookupdir files(idf).name];
    load(filename);
    
    input.parts = Environment.filter(input, environment.P_c);
    
    save(filename, 'input');
    cnt = cnt+1;
    loop_display(cnt);
end


% num_wpns = 0:50:200;
% num_sps =  0:50:200;
% cnt = 100;
%     for id_sp = 1:numel(num_wpns)
%         for id_wpn = 1:numel(num_sps)
%             input.parts = Environment.filter(input, P_c);
%%
clearvars
num_sp = 0;
num_wpn = 0;
% name = 'large_flat';
input = Experiments.Diss.large_flat(num_sp, num_wpn);
%%
[P_c, E_r] = mb.polygonConvexDecomposition(input.environment.combined);
P_c = cellfun(@(x) mb.visilibity2boost(x), P_c, 'uniformoutput', false);
%%
load tmp\large_flat\environment\environment.mat
environment.P_c = P_c;
environment.E_r = E_r;
save tmp\large_flat\environment\environment.mat environment
%%
lookupdir = 'tmp/large_flat/discretization/';
files = dir([lookupdir '*.mat']);

%%
iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(files);
for idf = 1:numel(files)
    filename = [lookupdir files(idf).name];
    load(filename);
    
    input.parts = Environment.filter(input, environment.P_c);
    save(filename, 'input');
    
    iteration = iteration + 1;
    if toc(tme)>next
        fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
        next = toc(tme)+stp;
    end
end


%%
clearvars
num_sp = 0;
num_wpn = 0;
% name = 'large_flat';
input = Experiments.Diss.office_floor(num_sp, num_wpn);
%%
[P_c, E_r] = mb.polygonConvexDecomposition(input.environment.combined);
P_c = cellfun(@(x) mb.visilibity2boost(x), P_c, 'uniformoutput', false);
%%
figure, hold on;
for idp = 1:numel(P_c)
    
    h = mb.drawPolygon(P_c{idp});
    pause;
    set(h, 'color', 'g');
end


%%
load tmp\office_floor\environment\environment.mat
environment.P_c = P_c;
environment.E_r = E_r;
save tmp\office_floor\environment\environment.mat environment
%%
lookupdir = 'tmp/office_floor/discretization/';
files = dir([lookupdir '*.mat']);

%%
iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(files);
for idf = 1:numel(files)
    filename = [lookupdir files(idf).name];
    load(filename);
    
    input.parts = Environment.filter(input, environment.P_c);
    save(filename, 'input');
    
    iteration = iteration + 1;
    if toc(tme)>next
        fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
        next = toc(tme)+stp;
    end
end