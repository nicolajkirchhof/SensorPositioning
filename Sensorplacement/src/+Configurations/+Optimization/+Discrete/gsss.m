function model = gsss(common)
%% GENERIC generic configuration of common variables

if nargin < 1
    common = Configurations.Common.generic(mfilename());
end

model = Configurations.Optimization.Discrete.generic(common);
model.type = mfilename();
model.quality.min = 0.58;
model.is_relax = true;

model.header = []; % user defined header of comments to file e.g. \Problem name: xyz
%         [~, name, ~] = fileparts(fn(idws).name);
%         modname = [mt '_' name];
%% TEMP
return;
%%
config = Configurations.Optimization.Discrete.mssqm;



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
