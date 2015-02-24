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

    cmcqm_nonlin_it{id_sp, id_wpn} = solution;
end
%%
save(sprintf('tmp/%s/cmqm_nonlin_it.mat', name), 'cmqm_nonlin_it');
end
%%
load(sprintf('tmp/%s/gco.mat', name));
load(sprintf('tmp/%s/gcss.mat', name));
load(sprintf('tmp/%s/gsss.mat', name));
load(sprintf('tmp/%s/stcm.mat', name));
% load(sprintf('tmp/%s/mspqm.mat', name));

