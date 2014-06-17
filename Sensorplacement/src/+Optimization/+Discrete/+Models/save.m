function config = save( config )
%FINISH combines the tempfiles to a .lp file

if config.common.debug
    return;
end

% if isempty(pc.name)
%     warning('no model name given, using environment file name');
%     [~, basename] = fileparts(pc.environment.file);
%     pc.name = basename;
% end

% outname = [pc.common.workdir '/' pc.name];
% sel_models = [];
% for model_name = fieldnames(pc.model.types)'
%     model_name = model_name{1};
%     if pc.model.(model_name).enable
%         outname = [outname pc.model.(model_name).tag];
%         sel_models{end+1} = model_name;
%         % elseif pc.model.config.
%         %     outname = [outname '_dist'];
%     end
% end
% outname = [config.common.workdir '/' config.filename '.lp'];
outname = config.filename;
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
    if ~isempty(config.header)
        system(sprintf('echo >> %s', config.header));
    end
    for modelfiletype = fieldnames(config.filehandles)'
        system(modelfile.(modelfiletype{1}).header);
        fun_addfile2model(config.tempfilenames.(modelfiletype{1}));
        system(['echo. >> ' outname]);
    end
    system(['echo END >> ' outname]);
end
write_log('...done ');
% config.progress.model.saved = true;
% config.model.lastsave = outname;
return;

%%  TEST
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality); 

config = Configurations.Optimization.Discrete.stcm;

config = Optimization.Discrete.Models.init(config);
Optimization.Discrete.Models.Objective.sum_sensors(discretization, config);
config = Optimization.Discrete.Models.finish(config);
config.filename = 'test.lp';
%%
Optimization.Discrete.Models.save(config);


