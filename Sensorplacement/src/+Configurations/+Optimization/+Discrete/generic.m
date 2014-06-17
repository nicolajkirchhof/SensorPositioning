function model = generic()
%% GENERIC generic configuration of common variables

% model_types = {'ws', 'wss', 'it'};
model.filetypes = struct('obj',0, 'st',0,  'bounds',0, 'bin',0, 'general',0); % types of tmp files

model.header = []; % user defined header of comments to file e.g. \Problem name: xyz
%         [~, name, ~] = fileparts(fn(idws).name);
%         modname = [mt '_' name];
model.tag = [];
model.name = [];
% model.types = modname;
% model.id = 0;
% model.tag = tag;
% model.enable = false;
model.quality.min = 0;
model.quality.max = 1;
model.quality.reject = 0;
model.file.open = false;
% for modft = model.filetypes
%     modft = modft{1};
%     model.(modft).filename = {}; % cell array of files to be combined
%     model.(modft).fid = []; % fids of files
%     model.(modft).enable = true; % fids of files
% end