function [ scalCopy ] = copyScal( scal )
%COPYSCAL Summary of this function goes here
%   Detailed explanation goes here
    scalCopy = syscal;
    
    propnames = fieldnames(scal);
    for i =1:numel(propnames)
        scalCopy.(propnames{i}) = scal.(propnames{i});
    end

end

