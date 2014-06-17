function sol = read_solution_it(problemfile)

% get full path
[path, base] = fileparts(problemfile);
if ~isempty(strtrim(path))
    addpath(path);
end
problemfile = which(problemfile);
sol_file = [path '\' base '.sol'];
if ~exist(sol_file, 'file')
    warning('solution to file %s does not exist', problemfile);
    return;
end
%%
% solution = xml2struct([path base '.sol']);
% PARSEXML Convert XML file to a MATLAB structure.
NET.addAssembly('System.Xml');
%%
%// Set the reader settings.
settings = System.Xml.XmlReaderSettings();
settings.IgnoreComments = true;
settings.IgnoreProcessingInstructions = true;
settings.IgnoreWhitespace = true;
settings.CheckCharacters = false;

xmlreader = System.Xml.XmlReader.Create(sol_file, settings);
%%
% try
%     tree = xmlread(sol_file);
% catch
%     error('Failed to read XML file %s.',problemfile);
% end
%
sol = [];
sol.header.problemName = @(x) char(x);
sol.header.solutionName = @(x) char(x);
sol.header.solutionIndex = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.header.objectiveValue = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.header.solutionTypeValue = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.header.solutionTypeString = @(x) char(x);
sol.header.solutionStatusValue = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.header.solutionStatusString = @(x) char(x);
sol.header.solutionMethodString = @(x) char(x);
sol.header.primalFeasible = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.header.dualFeasible = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.header.MIPNodes = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.header.MIPIterations = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.header.writeLevel = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.quality.epInt = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.quality.epRHS = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.quality.maxIntInfeas = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.quality.maxPrimalInfeas = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.quality.maxX = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.quality.maxSlack = @(x) System.Xml.XmlConvert.ToDouble(x);
sol.linearConstraints.name = {};
sol.linearConstraints.index = {}; 
sol.linearConstraints.slack = {};
sol.variables.name = {};
sol.variables.index = {}; 
sol.variables.value = {};


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
%             disp(xmlreader.Name);            
            el_name = char(xmlreader.Name);
            write_log(' reading %s ...', el_name);
            switch el_name
                case {'header', 'quality'}
                    while (xmlreader.MoveToNextAttribute())
                        name = char(xmlreader.Name);
                        value = xmlreader.Value;
                        sol.(el_name).(name) = sol.(el_name).(name)(value);
                    end
                 case {'linearConstraints', 'variables'}
                     cnt = 1;
                    fcache1 = fopen(fname1, 'W');
                    fcache2 = fopen(fname2, 'W');
                    while xmlreader.Read() && xmlreader.NodeType ~= System.Xml.XmlNodeType.EndElement
%                         strfind(char(xmlreader.Name), 'constraint')
%                         fprintf('%s %s %d\n', char(xmlreader.Name), char(xmlreader.Value), xmlreader.NodeType ~= System.Xml.XmlNodeType.EndElement);
                        while (xmlreader.MoveToNextAttribute())
                            name = char(xmlreader.Name);                            
                            value = xmlreader.Value;
%                             fprintf('  %s %s \n', name, char(value));
                            switch name
                                case 'name'
                                    sol.(el_name).(name){end+1} = char(value);
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
                            sol.linearConstraints.index = fread(fcache1, inf, '*double');
                            sol.linearConstraints.slack = fread(fcache2, inf, '*double');
%                             sol.linearConstraints.slack = cell2mat(sol.linearConstraints.slack(sol.linearConstraints.index+1));
%                             sol.linearConstraints.index = sol.linearConstraints.index(sol.linearConstraints.index+1);
                        case 'variables'
                            sol.variables.index = fread(fcache1, inf, '*double');
                            sol.variables.value = fread(fcache2, inf, '*double');
%                             sol.variables.value = cell2mat(sol.variables.value(sol.variables.index+1));
%                             sol.variables.index = sol.variables.index(sol.variables.index+1);
                    end
                    fclose(fcache1);
                    fclose(fcache2);
            end
            write_log('...done ', el_name);
        case System.Xml.XmlNodeType.EndElement%// The node is an element.
%             disp('end');
    end
end
delete(fname1);
delete(fname2);
xmlreader.Close();
%%
% solution struct
% s.name = base;
% s.status = [];
% s.statusstring = [];
% % s.time = [];
% % s.dettime = [];
% s.objval = [];
% s.x = [];
% s.method = [];
% s.mipitcnt = [];
% s.ax = [];
% s.bestobjval = [];
% s.cutoff = [];
% s.miprelgap = [];
% s.primalFeasible = [];
% s.quality.epInt = [];
% s.quality.epRHS = [];
% s.quality.maxIntInfeas= [];
% s.quality.maxPrimalInfeas=[];
% s.quality.maxX=[];
% s.quality.maxSlack=[];
% s.linearConst.names = {};
% s.linearConst.slacks = [];
% s.variables.names = {};
% s.variables.values = [];
sol.ax = abs(sol.linearConstraints.slack);
sol.x = sol.variables.value;
sol.sensor.names = sol.variables.name(sol.variables.value(1:numel(sol.variables.name))==1);
solstr = cellfun(@(str) sscanf(str, 's%d'), sol.sensor.names, 'uniformoutput', false);
solstr = solstr(~cellfun(@isempty, solstr));
sol.sensor.ids = unique(cell2mat(solstr'));
% combstr = cellfun(@(str) sscanf(str, 's%ds%d'), sol.sensor.names, 'uniformoutput', false);
% 
combnums = cellfun(@(str) sscanf(str, 's%ds%d'), sol.sensor.names, 'uniformoutput', false);
combnums_flt = cellfun(@(x) numel(x)>1, combnums);
sol.sensor.comb =  cell2mat(combnums(combnums_flt))';


write_log('...done');