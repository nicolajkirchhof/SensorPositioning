function write(pc)
%WRITE_MODELS Summary of this function goes here
%   Detailed explanation goes here

if isempty(pc.model.cplex.filename)
    warning('no model name given, using no_name.lp');
    pc.model.cplex.filename = 'no_name.lp';
end

if isempty(pc.name) || ~isempty(pc.environment.file)
    [pathstr, pc.name, ext] = fileparts(pc.environment.file);
else
    warning('no model name given');
    pc.name = 'none';
end
    c = Cplex(pc.name);
    model.copy2cplex(pc.model.cplex, c);
    c.writeModel([pc.model.cplex.filename pc.model.cplex.filetype]);
end

