function model = stcm(common)
%% GENERIC generic configuration of common variables

if nargin < 1
    common = Configurations.Common.generic('stcm');
end

model.common = common;
model.type = 'stcm';
% model_types = {'ws', 'wss', 'it'};

model.filehandles = struct('obj',1, 'st',1,  'bounds',1, 'bin',1, 'general',1); % types of tmp files

fn = fieldnames(model.filehandles);
model.tempfilenames = [];
for type = fn'
    fn = sprintf('%s/%s_%s.tmp', common.workdir, model.type, type{1});
    model.tempfilenames.(type{1}) = fn;
end


model.header = []; % user defined header of comments to file e.g. \Problem name: xyz
%         [~, name, ~] = fileparts(fn(idws).name);
%         modname = [mt '_' name];
%% TEMP
return;
%%
config = Configurations.Optimization.Discrete.stcm;



% model.tag = ['_stcm'];
% model.types = modname;
% model.id = 0;
% model.tag = tag;
% model.enable = false;
% model.quality.min = 0;
% model.quality.max = 1;
% model.quality.reject = 0;
% model.file.open = false;
% for modft = model.filetypes
%     modft = modft{1};
%     model.(modft).filename = {}; % cell array of files to be combined
%     model.(modft).fid = []; % fids of files
%     model.(modft).enable = true; % fids of files
% end
