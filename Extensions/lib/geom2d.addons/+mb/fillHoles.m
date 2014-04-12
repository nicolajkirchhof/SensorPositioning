function varargout = fillHoles(bpoly, varargin)
%polygonArea for boost polygon
vpolys = mb.select_holes(mb.boost2visilibity(bpoly));
fillPolygon(vpolys, varargin{:});

