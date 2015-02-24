%% Add decomposition parts
clearvars;
names = {'conference_room', 'small_flat', 'large_flat'}; %, 'office_floor'};

% for idn = 1:numel(names)
    name = names{idn};
    filename = sprintf('tmp/%s/mspqm.mat', name);
    load(filename);
    %%
    for idm = 1:numel(mspqm)
        if ~isempty(mspqm{idm})
            mspqm{idm}.num_sp = mspqm{idm}.num_sensors_additonal;
            mspqm{idm}.num_wpn = mspqm{idm}.num_positions_additional;
        else
            mspqm(idm) = [];
        end
    end
    %%
    save(sprintf('tmp/%s/mspqm.mat', name), 'mspqm');
    
% end