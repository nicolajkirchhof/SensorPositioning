function draw_multipolygon(mp, varargin)
% draws all polygon contours that is defined according to boost standards in matlab

for idp = 1:numel(mp)
    p = mp{idp};
    hold on;
    for idc = 1:numel(p)
        drawPolygon(p{idc}', varargin{:});
    end
end
