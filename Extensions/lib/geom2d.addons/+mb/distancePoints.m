function dist = distancePoints(varargin)
%wrapper for transposed points

varargin = cellfun(@fun_transp, varargin, 'uniformoutput', false);
dist = distancePoints(varargin{:});

function x = fun_transp(x)
if isnumeric(x)
    x = double(x');
end