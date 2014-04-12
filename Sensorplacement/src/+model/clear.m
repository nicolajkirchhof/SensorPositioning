function [ pc ] = clear( pc, types )
%CLEAR closes all filehandles and resets fids
if nargin < 2
    types = fieldnames(pc.model.types);
end
if ischar(types)
    types = {types};
end
%% clear progress
%%% if model was already in use, clear progress and re init
for type = types(:)'
    type = type{1};
if ~pc.progress.model.(type)
    write_log('%s model was not build ... doint nothing', type);
%     return;
else
    write_log('resetting %s model', type);
    pc.model.(type).enable = false;
    pc.progress.model.(type) = false;
end
end

    
    %% clear file handles
if pc.common.debug
    % fopen points to console do nothing
    return;
end
% 
%     for ftype = pc.model.filetypes
%         fclose(pc.model.file.(ftype{1}).fids(pc.model.(type).id));
%     end

end

