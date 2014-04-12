function [ rec ] = convRecord2Mat( scal )
%CONVRECORD2MAT Summary of this function goes here
%   Detailed explanation goes here
%%
rec = zeros(numel(scal.stateCurrent), numel(scal.record));
for i = 1:numel(scal.record)
    rec(:,i) = scal.record{i}.stateCurrent; 
end

end

