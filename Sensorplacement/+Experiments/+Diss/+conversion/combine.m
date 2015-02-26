clearvars;
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
for idn = 1:numel(names)
% idn = 1;
name = names{idn};
lookupdir = sprintf('tmp/%s/cmqm/', name);
files = dir([lookupdir '*.mat']);
%%
cmqm_nonlin_it = {};
for idf = 1:numel(files)
    file = files(idf);
    filename = [lookupdir file.name];
    load(filename);
    id_sp = solution.num_sp/10 + 1;
    id_wpn = solution.num_wpn/10 + 1;

    cmqm_nonlin_it{id_sp, id_wpn} = solution;
end
%%
save(sprintf('tmp/%s/cmqm_nonlin_it.mat', name), 'cmqm_nonlin_it');
end


%%
clearvars;
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
% for idn = 1:numel(names)
idn = 2;
name = names{idn};
%%
load(sprintf('tmp/%s/gco.mat', name));
load(sprintf('tmp/%s/gcss.mat', name));
load(sprintf('tmp/%s/gsss.mat', name));
load(sprintf('tmp/%s/stcm.mat', name));
load(sprintf('tmp/%s/stcm.mat', nameh));
load(sprintf('tmp/%s/cmqm_nonlin_it.mat', name));
load(sprintf('tmp/%s/cmqm_cmaes_it.mat', name));
%%
opt_names = {'gco', 'gcss', 'gsss', 'mspqm', 'stcm', 'cmqm_nonlin_it', 'cmqm_cmaes_it'};
opt = [];
for idn = 1:numel(opt_names)
    opt_name = opt_names{idn};
    load(sprintf('tmp/%s/%s.mat', name, opt_name));
    opt.(opt_name) = eval([opt_name ';']);
end
eval(sprintf('%s = opt;', name));
%%
save(sprintf('tmp/%s.mat', name), name);

