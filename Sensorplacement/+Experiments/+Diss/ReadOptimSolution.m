%% Add decomposition parts
clearvars;
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
idn = 3;
name = names{idn};
% load(sprintf('tmp/%s.mat', name));
opt_name = 'bspqm';
lookupdir = sprintf('tmp/%s/', opt_name);
files = dir(sprintf('%s*%s*.mat', lookupdir, name));
loop_display(numel(files), 5);
bspqm = cell(51, 51);
%%
for idf = 1:numel(files)
    %%
    file = files(idf);
    matfile = [lookupdir file.name];
    load(matfile);
    %%
    id_sp = solution.num_sp/10 + 1;
    id_wpn = solution.num_wpn/10 + 1;
    bspqm{id_sp, id_wpn} = solution;
    %     end
    loop_display(idf);
end
%%
save(sprintf('tmp/%s/%s.mat', name, opt_name), opt_name);
