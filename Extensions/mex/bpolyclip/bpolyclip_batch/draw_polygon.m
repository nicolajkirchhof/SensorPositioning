function draw_polygon(p, varargin)
% draws all polygon contours that is defined according to boost standards in matlab
for idc = 1:numel(p)
    drawPolygon(p{idc}', varargin{:});
end
