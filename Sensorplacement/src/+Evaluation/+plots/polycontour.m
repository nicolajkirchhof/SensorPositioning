function draw_polycontour(p, varargin)

for i=1:numel(p)
    drawPolygon(p(i).x, p(i).y, varargin{:});
end