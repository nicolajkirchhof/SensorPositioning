function hPoly = drawPolygon(bpoly, varargin)
%polygonArea for boost polygon
poly = mb.boost2visilibity(bpoly);
axis equal
if any(strcmpi(varargin, 'random'));
    hpolys = drawPolygon(poly);
    colors = hsv(numel(hpolys));
    color_ids = randperm(numel(hpolys));
    colors = colors(color_ids, :);
    for idply = 1:numel(hpolys)
        set(hpolys(idply), 'Color', colors(idply, :));
    end
    return;
end

if nargout > 0
    hPoly = drawPolygon(poly, varargin{:});
else
    drawPolygon(poly, varargin{:});
end