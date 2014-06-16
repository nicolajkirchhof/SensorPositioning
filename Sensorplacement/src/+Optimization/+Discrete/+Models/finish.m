function [ config ] = finish( config )
%INIT Closes the tempfiles and sets the progress
% %%
% Maximize
%  obj: x1 + 2 x2 + 3 x3 + x4
% Subject To
%  c1: - x1 + x2 + x3 + 10 x4 <= 20
%  c2: x1 - 3 x2 + x3 <= 30
%  c3: x2 - 3.5 x4 = 0
% Bounds
%  0 <= x1 <= 40
%  2 <= x4 <= 3
% General
%  x4
% Binaries
% SOS
% set1: S1:: x1:10 x2:13
% End

if config.common.debug
    % direct all fprint streams to console
%     pc.model.file.obj.fids = 1;
%     pc.model.file.bounds.fids = 1;
%     pc.model.file.st.fids = 1;
%     pc.model.file.bin.fids = 1;
%     pc.model.file.general.fids = 1;
    return;
end
%%
for type = fieldnames(config.filehandles)'
    if config.filehandles.(type{1}) > 1
        config.filehandles.(type{1}) = fclose(config.filehandles.(type{1}));
        if config.filehandles.(type{1}) == 0
            config.filehandles.(type{1}) = 1
        else
            error('fclose did not succseed');
        end
    else
        error('file of model %s not valid', mtype);
    end
end

return;
%% 
config = Configurations.Optimization.Discrete.stcm;
config = Optimization.Discrete.Models.init(config);
config = Optimization.Discrete.Models.finish(config);