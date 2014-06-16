function model = generic()
%% GENERIC generic configuration of common variables


%% TODO: add dirdist_comb
model_types = {'ws', 'wss', 'it'};
pc.model.filetypes = {'obj', 'st', 'bounds', 'bin', 'general'}; % types of tmp files
pc.model.header = []; % user defined header of comments to file e.g. \Problem name: xyz
for mt = model_types
    mt = mt{1};
    fn = dir(['src' filesep '+model' filesep '+' mt filesep '*.m']);
    % ws_quality_types = {'ws_distance'};
    % ws_quality_tags = {'_wsdist'};
    % ws_quality_funs = {@quality.dist}
    for idws = 1:numel(fn)
        [~, name, ~] = fileparts(fn(idws).name);
        modname = [mt '_' name];
        tag = ['_' name];
        pc.model.types.(modname) = modname;
        pc.model.(modname).id = 0;
        pc.model.(modname).tag = tag;
        pc.model.(modname).enable = false;
        pc.model.(modname).quality.min = 0;
        pc.model.(modname).quality.max = 1;
        pc.model.(modname).quality.reject = 0;
        for mtq = model_types            
        pc.model.(modname).quality.(mtq{1}).name = [];
        pc.model.(modname).quality.(mtq{1}).param = 1;
        end          
        pc.model.(modname).file.open = false;
        for modft = pc.model.filetypes
        modft = modft{1};
        pc.model.(modname).(modft).filename = {}; % cell array of files to be combined
        pc.model.(modname).(modft).fid = []; % fids of files
        pc.model.(modname).(modft).enable = true; % fids of files
        end
    end
end
