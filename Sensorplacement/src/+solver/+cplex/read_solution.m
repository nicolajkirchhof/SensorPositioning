function s = read_solution(problemfile)
[path, base] = fileparts(problemfile);
sol_file = [path '\' base '.sol'];
if ~exist(sol_file, 'file')
    warning('solution to file %s does not exist', problemfile);
    return;
end
%%
% solution = xml2struct([path base '.sol']);
% PARSEXML Convert XML file to a MATLAB structure.
try
    tree = xmlread(sol_file);
catch
    error('Failed to read XML file %s.',problemfile);
end
%%
% solution struct
s.name = base;
s.status = [];
s.statusstring = [];
% s.time = [];
% s.dettime = [];
s.objval = [];
s.x = [];
s.method = [];
s.mipitcnt = [];
s.ax = [];
s.bestobjval = [];
s.cutoff = [];
s.miprelgap = [];
s.primalFeasible = [];
s.quality.epInt = [];
s.quality.epRHS = [];
s.quality.maxIntInfeas= [];
s.quality.maxPrimalInfeas=[];
s.quality.maxX=[];
s.quality.maxSlack=[];
s.linearConst.names = {};
s.linearConst.slacks = [];
s.variables.names = {};
s.variables.values = [];

% problemName="IloCplex"
% solutionName="incumbent"
% solutionIndex="-1"
% objectiveValue="6"
% solutionTypeValue="3"
% solutionTypeString="primal"
% solutionStatusValue="101"
% solutionStatusString="integer optimal solution"
% solutionMethodString="mip"
% primalFeasible="1"
% dualFeasible="1"
% MIPNodes="4"
% MIPIterations="512"
% writeLevel="1"/>
% s.pool: [1x1 struct]
%%
doc = tree.getDocumentElement();
header = doc.getElementsByTagName('header').item(0);
s.statusstring = char(header.getAttribute('solutionStatusString'));
s.method = char(header.getAttribute('solutionMethodString'));
s.status = str2double(header.getAttribute('solutionStatusValue'));
s.primalFeasible = str2double(header.getAttribute('primalFeasible'));
s.mipitcnt = str2double(header.getAttribute('MIPIterations'));
s.objval = str2double(header.getAttribute('objectiveValue'));
quality = doc.getElementsByTagName('quality').item(0);
for fn = fieldnames(s.quality)'
    s.quality.(fn{1}) = str2num(quality.getAttribute(fn{1}));
end
%%
linearConst = doc.getElementsByTagName('linearConstraints').item(0);
const = linearConst.getElementsByTagName('constraint');
num_const = const.getLength;
s.linearConst.names = cell(num_const, 1);
s.linearConst.slacks = zeros(num_const, 1);
write_log('reading constraints...');
loop_display(num_const, 10);
for idl = 1:num_const
    id = str2num(const.item(idl-1).getAttribute('index'));
    s.linearConst.names{id+1} = char(const.item(idl-1).getAttribute('name'));
    s.linearConst.slacks(id+1) = str2double(const.item(idl-1).getAttribute('slack'));
    if mod(idl,10000)
        loop_display(idl);
    end
end
s.ax = abs(s.linearConst.slacks);
write_log('...done');
%%
variables = doc.getElementsByTagName('variables').item(0);
vars = variables.getElementsByTagName('variable');
num_vars = vars.getLength;
s.variables.names = cell(num_const, 1);
s.variables.values = zeros(num_const, 1);
loop_display(num_vars, 10);
write_log('reading variables...');
for idl = 1:num_vars
    id = str2num(vars.item(idl-1).getAttribute('index'));
    s.variables.names{id+1} = char(vars.item(idl-1).getAttribute('name'));
    s.variables.values(id+1) = str2double(vars.item(idl-1).getAttribute('value'));
    if mod(idl,10000)
        loop_display(idl);
    end
end
s.x = s.variables.values;
write_log('...done');