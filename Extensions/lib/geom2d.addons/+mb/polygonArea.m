function area = polygonArea(poly, varargin)
%polygonArea for boost polygon
poly = mb.boost2visilibity(poly);
area = polygonArea(poly, varargin{:});
end

