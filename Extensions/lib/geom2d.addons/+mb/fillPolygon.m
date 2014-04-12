function hPoly = fillPolygon(bpoly, varargin)
%polygonArea for boost polygon
if iscell(bpoly)
    vpolys = mb.select_boundaries(mb.boost2visilibity(bpoly));
else
    vpolys = mb.boost2visilibity(bpoly);
end
% if nargin >= 2
    hPoly = fillPolygon(vpolys, varargin{:});
        
% else
%     fillPolygon(vpolys);
% end
