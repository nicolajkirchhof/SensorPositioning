function hPoly = drawPoint(points, varargin)
%polygonArea for boost polygon
if nargout > 0
hPoly = drawPoint(points', varargin{:});
else 
drawPoint(points', varargin{:});
end