clearvars;
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
% for idn = 1:numel(names)
idn = 4;
name = names{idn};
%%
lookupdir = sprintf('tmp/%s/cmcqm/', name);
files = dir([lookupdir 'cmaes*.mat']);
cmcqm_nonlin_it = cell(51, 51);
%%%
for idf = 1:numel(files)
    %%
%     idf = 6;
    file = files(idf);
     
    filename = [lookupdir file.name];
    load(filename);
    
    %%
    id_sp = solution.num_sp/10 + 1;
    id_wpn = solution.num_wpn/10 + 1;

    cmcqm_nonlin_it{id_sp, id_wpn} = solution;
end
%%
% save(sprintf('tmp/%s/cmcqm_cmaes_it.mat', name), 'cmcqm_cmaes_it');
save(sprintf('tmp/%s/cmcqm_nonlin_it.mat', name), 'cmcqm_nonlin_it');
% end
%%
for idc = 1:10:numel(cmcqm_cmaes_it_tmp)
    solution = cmcqm_cmaes_it_tmp{idc};
        id_sp = solution.num_sp/10 + 1;
    id_wpn = solution.num_wpn/10 + 1;
   cmcqm_cmaes_it{id_sp, id_wpn} = solution;

end
%%
clearvars;
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
% for idn = 1:numel(names)
idn = 3;
name = names{idn};
%%
load(sprintf('tmp/%s/gco.mat', name));
load(sprintf('tmp/%s/gcss.mat', name));
load(sprintf('tmp/%s/gsss.mat', name));
load(sprintf('tmp/%s/stcm.mat', name));
load(sprintf('tmp/%s/stcm.mat', nameh));
load(sprintf('tmp/%s/cmcqm_nonlin_it.mat', name));
load(sprintf('tmp/%s/cmcqm_cmaes_it.mat', name));
%%
opt_names = {'gco', 'gcss', 'gsss', 'mspqm', 'stcm', 'cmcqm_nonlin_it', 'cmcqm_cmaes_it'};
opt = [];
for idn = 1:numel(opt_names)
    opt_name = opt_names{idn};
    load(sprintf('tmp/%s/%s.mat', name, opt_name));
    opt.(opt_name) = eval([opt_name ';']);
end
%%
eval(sprintf('%s = opt;', name));
%%
save(sprintf('tmp/%s.mat', name), name);

