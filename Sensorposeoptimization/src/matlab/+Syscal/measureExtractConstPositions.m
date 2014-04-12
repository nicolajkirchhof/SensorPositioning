%% Extract Constant Positions
% Extracts sensor data for parts of the recording where the person has been
% standing at the same position. 
% As output a cell array with all data at this positions is given.
%% get pose estimation data

function outData = measureExtractConstPositions(inData, inPositions)
%% 

refdiff = [[1,1,1] ; diff(inPositions)];
refidx = ~(refdiff(:,1)|refdiff(:,2)|refdiff(:,3));

outData = ref.data(refidx, :);
inData;

end