[path, base, ext] = fileparts(mfilename('fullpath'));
exts = dir([path filesep 'ext_*.m']);
for ide = 1:numel(exts)
    if strcmp(exts(ide).name, [base '.m'])
        continue
    end
    run([path filesep exts(ide).name]);
end
% 
% run ext_f_LectDxf.m
% run ext_geom2d_addons.m
% run ext_jsonlab.m
% run ext_logging.m
% run ext_matgeom.m
% run ext_mex.m
% run ext_tools_general.m
% run ext_tools_io.m
% run ext_tools_math.m
% run ext_wkt.m