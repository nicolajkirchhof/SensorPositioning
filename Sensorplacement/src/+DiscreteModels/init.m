function [ pc, id ] = init( pc, mtype )
%INIT Initializes the tempfiles for model writing
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

if pc.common.debug
    % direct all fprint streams to console
    pc.model.file.obj.fids = 1;
    pc.model.file.bounds.fids = 1;
    pc.model.file.st.fids = 1;
    pc.model.file.bin.fids = 1;
    pc.model.file.general.fids = 1;
    return;
end
%%
if ~pc.model.(mtype).file.open
    for type = pc.model.filetypes
        fn = sprintf('%s/%s%s.tmp', pc.common.workdir, type{1}, pc.model.(mtype).tag);
        pc.model.(mtype).(type{1}).file = fn;
        pc.model.(mtype).(type{1}).fid = fopen(fn, 'W');
    end
    pc.model.(mtype).file.open = true;
else
    error('file of model %s already open', mtype);
end
