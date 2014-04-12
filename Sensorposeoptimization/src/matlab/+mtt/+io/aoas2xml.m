function aoas2xml( aoas, filename, minscore, maxscore )
%aoas2xml saves the data provided in struct ireg into an xml file
%   the xml-file structure is as followed
%       <arrayofarrayofanglesensordata xmlns:xsi="http://www.w3.org/2001/xmlschema-instance" xmlns:xsd="http://www.w3.org/2001/xmlschema">
  % <arrayofanglesensordata>
    % <anglesensordata>
      % <angle>22.993710691823903</angle>
      % <score>128.26123046875</score>
    % </anglesensordata>
    % <anglesensordata xsi:nil="true" />
    % <anglesensordata xsi:nil="true" />
    % <anglesensordata xsi:nil="true" />
    % <anglesensordata xsi:nil="true" />
    % <anglesensordata>
      % <angle>16.754716981132077</angle>
      % <score>31.648273468017578</score>
    % </anglesensordata>
    % <anglesensordata xsi:nil="true" />
    % <anglesensordata>
      % <angle>5.18238993710692</angle>
      % <score>166.54275512695313</score>
    % </anglesensordata>
  % </arrayofanglesensordata>
  % ...
% </arrayofarrayofanglesensordata>
%

docnode = com.mathworks.xml.XMLUtils.createDocument('ArrayOfArrayOfAngleSensorData');
doc = docnode.getDocumentElement;

doc.setAttribute('xmlns:xsi', 'http://www.w3.org/2001/xmlschema-instance');
doc.setAttribute('xmlns:xsd', 'http://www.w3.org/2001/xmlschema');

for i = 1:numel(aoas)
    nodearr = docnode.createElement('ArrayOfAngleSensorData');
    doc.appendChild(nodearr);
    %%
    for j = 1:size(aoas{i},1)
        node = docnode.createElement('AngleSensorData');
        nodearr.appendChild(node);
        if aoas{i}(j,4) > minscore && aoas{i}(j,4) < maxscore 
            aoa = docnode.createElement('Angle');
            aoa.setTextContent(num2str(aoas{i}(j,3)));
            score = docnode.createElement('Score');
            score.setTextContent(num2str(aoas{i}(j,4)));
            node.appendChild(aoa);
            node.appendChild(score);
        else
            node.setAttribute('xsi:nil', 'true');
        end
    end
end

if ~isempty(filename)
    xmlwrite(filename,docnode);
end
