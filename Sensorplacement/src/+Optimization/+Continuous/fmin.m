function [ pc ] = fmin( pc )
%START Solves the sensorplacement by approximation of the
% total number of sensors and an iterative nonlinear search
%%
[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
model_type = [model_prefix '_' model_name];
% model_type = 'it_fmin';
if pc.progress.model.(model_type)
    pc = model.enable(pc, model_type);
    return;
end

fun_mapprox = pc.model.(model_type).quality.fct;
% mapprox = pc.model.(model_type).quality.name;
if isa(fun_mapprox, 'function_handle') 
    %     pc.model.(mapprox).quality.param = pc.model.(model_type).quality.param;
    write_log(' ... calculating approximate solution for model %s', model_type);
    pc = fun_mapprox(pc);
    pc = model.save(pc);
    sol = solver.cplex.startext(pc.model.lastsave);
    
    solnames = sol.variables.name(sol.x>0);
    sol.sensors = unique(cell2mat(cellfun(@(str) sscanf(str, 's%d'), solnames, 'uniformoutput', false)));
    sol.num_sensors = numel(sol.sensors);
    pc.model.(model_type).sol = sol;
    write_log('...done ');
else
    error('cannot create model %s', model_type);
end

% [pc] = model.init(pc, model_type);
%%





%%
pc = model.finish(pc, model_type);
% write_log('... done ');
return;
%%
