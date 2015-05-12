%% Add decomposition parts
clearvars;
names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
idn = 1;
name = names{idn};
lookupdir = sprintf('tmp/%s/discretization/', name);
files = dir(sprintf('%s*.mat', lookupdir));
loop_display(numel(files), 5);
%%
for idf = 1:numel(files)
    %%
    file = files(idf);
    matfile = [lookupdir file.name];
    load(matfile);
    input = rmfield(input, 'parts');
    %%
    save(matfile, 'input');
    %     end
    loop_display(idf);
end
%%
% save(sprintf('tmp/%s/%s.mat', name, opt_name), opt_name);
%%
input.discretization.wpn = uint32(input.discretization.wpn);
input.discretization.vfovs = cellfun(@uint32, input.discretization.vfovs, 'uniformoutput', false);