function pc = save( pc )
%FINISH combines the tempfiles to a .lp file

if pc.common.debug
    return;
end

if isempty(pc.name)
    warning('no model name given, using environment file name');
    [~, basename] = fileparts(pc.environment.file);
    pc.name = basename;
end

outname = [pc.common.workdir '/' pc.name];
sel_models = [];
for model_name = fieldnames(pc.model.types)'
    model_name = model_name{1};
    if pc.model.(model_name).enable
        outname = [outname pc.model.(model_name).tag];
        sel_models{end+1} = model_name;
        % elseif pc.model.config.
        %     outname = [outname '_dist'];
    end
end
outname = [outname '.lp'];
os = getenv('OS');
if strfind(os, 'Windows')
    fun_conv_path = @(x) strrep(x, '/', '\');
    freadcmd = 'type';
else
    fun_conv_path = @(x) strrep(x, '\', '/');
    freadcmd = 'cat';
end
outname = fun_conv_path(outname);
fun_addfile2model = @(file) system(sprintf('%1$s %2$s >> %3$s && echo. >> %3$s', freadcmd, fun_conv_path(file), outname));
%%
write_log(' writing problem to file %s...',outname);
% {'obj', 'st', 'bounds', 'bin', 'general'}
modelfile.obj.header = sprintf('echo Minimize >> %s', outname);
modelfile.st.header = sprintf('echo Subject To >> %s', outname);
modelfile.bin.header = sprintf('echo Binary >> %s', outname);
modelfile.bounds.header = sprintf('echo Bounds >> %s', outname);
modelfile.general.header = sprintf('echo General >> %s', outname);
if strfind(os, 'Windows')
    %% open file by writing a newline
    system(sprintf('echo. > %s', outname));
    for modelfiletype = pc.model.filetypes
        system(modelfile.(modelfiletype{1}).header);
        for model = sel_models
            if pc.model.(model{1}).(modelfiletype{1}).enable
                fun_addfile2model(pc.model.(model{1}).(modelfiletype{1}).file);
            else
                write_log('param %s of model %s where not written',modelfiletype{1} ,model{1});
            end
        end
        system(['echo. >> ' outname]);
    end
    system(['echo END >> ' outname]);
end
write_log('...done ');
pc.progress.model.saved = true;
pc.model.lastsave = outname;
