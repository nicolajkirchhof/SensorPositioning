function data = SensorDataXmlParser(filename)

doc = xmlread(filename);

measures = doc.getElementsByTagName('ArrayOfAngleSensorData');

data.aoas = [];
data.score = [];

for i = 0:measures.getLength-1;
    measure = measures.item(i);
    
    sensors = measure.getElementsByTagName('AngleSensorData');
    
    for j = 0:sensors.getLength-1
        sensor = sensors.item(j);
        %discard dummy nodes
      %   if sensor.getNodeType ~= 3
            %are values stored
            if  sensor.hasChildNodes
                vector = eval(['[' sensor.getTextContent.toCharArray' ']']);                
                data.aoas(j+1,i+1) = deg2rad(vector(1));
                data.score(j+1,i+1) = vector(2);
            end
       % end
    end
end