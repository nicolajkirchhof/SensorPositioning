function solution = read_solution(solutionfile)

if ~exist(solutionfile, 'file')
    error('solution to file %s does not exist', solutionfile);
    return;
end
%%%
% solution = xml2struct([path base '.sol']);
% PARSEXML Convert XML file to a MATLAB structure.
NET.addAssembly('System.Xml');
%%%
%// Set the reader settings.
settings = System.Xml.XmlReaderSettings();
settings.IgnoreComments = true;
settings.IgnoreProcessingInstructions = true;
settings.IgnoreWhitespace = true;
settings.CheckCharacters = false;

xmlreader = System.Xml.XmlReader.Create(solutionfile, settings);
%%%
solution = DataModels.solution();
solution.header.problemName = @(x) char(x);
solution.header.solutionName = @(x) char(x);
solution.header.solutionIndex = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.header.objectiveValue = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.header.solutionTypeValue = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.header.solutionTypeString = @(x) char(x);
solution.header.solutionStatusValue = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.header.solutionStatusString = @(x) char(x);
solution.header.solutionMethodString = @(x) char(x);
solution.header.primalFeasible = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.header.dualFeasible = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.header.MIPNodes = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.header.MIPIterations = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.header.writeLevel = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.quality.epInt = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.quality.epRHS = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.quality.maxIntInfeas = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.quality.maxPrimalInfeas = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.quality.maxX = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.quality.maxSlack = @(x) System.Xml.XmlConvert.ToDouble(x);
solution.linearConstraints.name = {};
solution.linearConstraints.index = {}; 
solution.linearConstraints.slack = {};
solution.variables.name = {};
solution.variables.index = {}; 
solution.variables.value = {};


% 
% function read_header()
% %     while xmlreader.Read() && xmlreader.NodeType ~= 
%     
% end
tic;
uuid = java.util.UUID.randomUUID;
fname1 = sprintf('..\\tmp\\fcache0%s.cache', char(uuid));
fname2 = sprintf('..\\tmp\\fcache1%s.cache', char(uuid));
if exist(fname1, 'file')>0
    error('cannot write cache ');
end
d = 0;
while(xmlreader.Read())
    switch (xmlreader.NodeType)
        case System.Xml.XmlNodeType.Element %// The node is an element.
            el_name = char(xmlreader.Name);
            write_log(' reading %s ...\n', el_name);
            switch el_name
                case {'header', 'quality'}
                    while (xmlreader.MoveToNextAttribute())
                        name = char(xmlreader.Name);
                        value = xmlreader.Value;
                        solution.(el_name).(name) = solution.(el_name).(name)(value);
                    end
                 case {'linearConstraints', 'variables'}
                     cnt = 1;
                    fcache1 = fopen(fname1, 'W');
                    fcache2 = fopen(fname2, 'W');
                    while xmlreader.Read() && xmlreader.NodeType ~= System.Xml.XmlNodeType.EndElement
                        while (xmlreader.MoveToNextAttribute())
                            name = char(xmlreader.Name);                            
                            value = xmlreader.Value;
                            switch name
                                case 'name'
                                    solution.(el_name).(name){end+1} = char(value);
                                case {'index'}
                                    fwrite(fcache1, System.Xml.XmlConvert.ToDouble(value), 'double');
                                case {'slack', 'value'}
                                    fwrite(fcache2,  System.Xml.XmlConvert.ToDouble(value), 'double');
                            end
                            
                        end
                        if toc > 10
                            d = toc + d;
                            fprintf('toc %g value %d\n', d, cnt);
                            tic;
                        end
                        cnt = cnt + 1;
                    end
                    fclose(fcache1);
                    fclose(fcache2);
                    fcache1 = fopen(fname1);
                    fcache2 = fopen(fname2);
                    switch el_name
                        case 'linearConstraints'
                            solution.linearConstraints.index = fread(fcache1, inf, '*double');
                            solution.linearConstraints.slack = fread(fcache2, inf, '*double');
                        case 'variables'
                            solution.variables.index = fread(fcache1, inf, '*double');
                            solution.variables.value = fread(fcache2, inf, '*double');
                    end
                    fclose(fcache1);
                    fclose(fcache2);
            end
            write_log('...done\n ', el_name);
        case System.Xml.XmlNodeType.EndElement%// The node is an element.
    end
end
delete(fname1);
delete(fname2);
xmlreader.Close();
%%%
% solution struct
num_variables = numel(solution.variables.name);
loop_display(num_variables, 10);
if any(diff(solution.variables.index)~=1)
    error('nonlinear variable storage ');
end
% solution.sensors_selected = [];
% solution.sc_selected = [];

for id_var = 1:num_variables
    num_s = strfind(solution.variables.name{id_var}, 's');
    if sum(num_s>0) == 0
        num_w = strfind(solution.variables.name{id_var}, 'w');
        if ~isempty(num_w)
%             id_variable = solution.variables.index(id_var);
            id_wpn = sscanf(solution.variables.name{id_var}, 'w%d');
            solution.wpn_qualities(id_wpn) = solution.variables.value(id_var);
        end
    elseif  sum(num_s>0) == 1
%         id_variable = solution.variables.index(id_var);
        id_sensor = sscanf(solution.variables.name{id_var}, 's%d');
        if solution.variables.value(id_var) > 0
%             write_log('%s, %d\n', solution.variables.name{id_var}, id_sensor);
            solution.sensors_selected = [solution.sensors_selected, id_sensor];
        end
    elseif sum(num_s>0) == 2
        [id_sensors] = sscanf(solution.variables.name{id_var}, 's%ds%d');
        if solution.variables.value(id_var) > 0
%             write_log('%s, [%d %d]\n', solution.variables.name{id_var}, id_sensors);
            solution.sc_selected = [solution.sc_selected; id_sensors(:)'];
        end
    end
end

if isempty(solution.sensors_selected)
    solution.sensors_selected = unique(solution.sc_selected);
end

solution.iterations = solution.header.MIPIterations;
solution.name = solution.header.problemName;
solution.status = solution.header.solutionStatusValue;
solution.statusstring = solution.header.solutionStatusString;
solution.linearConstraints = {};
solution.variables = {};
%%
% solution.ax = abs(solution.linearConstraints.slack);
% solution.x = solution.variables.value;
% solution.sensor.names = solution.variables.name(solution.variables.value(1:numel(solution.variables.name))==1);
% solstr = cellfun(@(str) sscanf(str, 's%d'), solution.sensor.names, 'uniformoutput', false);
% solstr = solstr(~cellfun(@isempty, solstr));
% solution.sensor.ids = unique(cell2mat(solstr'));
% % combstr = cellfun(@(str) sscanf(str, 's%ds%d'), sol.sensor.names, 'uniformoutput', false);
% % 
% combnums = cellfun(@(str) sscanf(str, 's%ds%d'), solution.sensor.names, 'uniformoutput', false);
% combnums_flt = cellfun(@(x) numel(x)>1, combnums);
% solution.sensor.comb =  cell2mat(combnums(combnums_flt))';


write_log('...done ');

return;

%% TEST
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

config = Configurations.Optimization.Discrete.bspqm;
config.name = 'P1';
filename = Optimization.Discrete.Models.bspqm(discretization, quality, config);
%%%
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
[solutionfile, logfile] = Optimization.Discrete.Solver.cplex.start(filename, cplex);
[solution] = Optimization.Discrete.Solver.cplex.read_solution(solutionfile);