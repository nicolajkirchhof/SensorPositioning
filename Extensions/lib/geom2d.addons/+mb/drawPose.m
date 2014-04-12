function h = drawPose(p,varargin)
% draws a pose x, y, phi on the screen
length = max([diff(xlim) diff(ylim)])*0.1;
rays = createRay(p(1:2,:)', p(3,:)');
rays(:,3:4) = bsxfun(@plus, rays(:,1:2), rays(:,3:4)*length);

if nargout > 0
    h = [drawEdge(rays, varargin{:}); drawPoint(p(1:2,:)', 'marker', 'o', varargin{:})];
else
    drawEdge(rays, varargin{:});
    drawPoint(p(1:2,:)', 'marker', 'o', varargin{:})
end
