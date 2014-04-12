function sendCell2Aoa(c, aoaudp)
%SENDTS2AOA Summary of this function goes here
%   Detailed explanation goes here

for i = 1:numel(c)
    fwrite(aoaudp, c{i}(:), 'double');    
end

