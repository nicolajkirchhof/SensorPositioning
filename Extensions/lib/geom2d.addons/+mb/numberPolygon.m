function hPoly = numberPolygon(bpoly, varargin)
%polygonArea for boost polygon
polys = mb.flattenPolygon(bpoly);
polys = cellfun(@mb.correctPolygon, polys, 'uniformoutput', false);

fun_create_text = @(x, y, num) text(double(x), double(y), num2str(num));
for idp = 1:numel(polys)
    numbers = 1:size(polys{idp}, 2);
    hPoly = arrayfun(fun_create_text, polys{idp}(1,:),polys{idp}(2,:), numbers);
end

