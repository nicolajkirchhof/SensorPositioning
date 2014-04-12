function sendTsc2Aoa(tsc, aoaudp)
%SENDTS2AOA Summary of this function goes here
%   Detailed explanation goes here

tsnames = tsc.gettimeseriesnames;
for i = 1:numel(tsc.time)
    for j = 1:numel(tsnames)
        pack(:,j) = [j, tsc.(tsnames{j}).data(i,:)];
    end
    
    fwrite(aoaudp, pack(:), 'double');    

end

