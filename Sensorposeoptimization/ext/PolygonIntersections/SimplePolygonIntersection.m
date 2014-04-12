function [ P ] = SimplePolygonIntersection( P1, P2 )
%SIMPLEPOLYGONCLIP Summary of this function goes here
%   ONLY FOR CONVEX POLYGONS WITHOUT HOLES
% P1, P2 = [Nx2]
if isempty(which('GpcWrapper.Polygon'))
    p = mfilename('fullpath');
    p = fileparts(p);
    NET.addAssembly([p '/GpcWrapper.dll']);
end

Gpc_Type = GpcWrapper.GpcOperation.Intersection;

poly1 = GpcWrapper.Polygon;
poly2 = GpcWrapper.Polygon;

vl_tmp = GpcWrapper.VertexList(double(single(P1(:,1))), double(single(P1(:,2))));
poly1.AddContour(vl_tmp, false);
vl_tmp = GpcWrapper.VertexList(double(single(P2(:,1))), double(single(P2(:,2))));
poly2.AddContour(vl_tmp, false);


p_result = poly1.Clip(Gpc_Type, poly2);

%     for idx_contour = 1:p_result.NofContours
%         P(idx_contour).hole = p_result.ContourIsHole(idx_contour);
%         for idx_xy = 1:p_result.Contour(idx_contour).Vertex.Length
%             P(idx_contour).x(idx_xy) = p_result.Contour(idx_contour).Vertex(idx_xy).X;
%             P(idx_contour).y(idx_xy) = p_result.Contour(idx_contour).Vertex(idx_xy).Y;
%         end
%     end
%Except Convex Poly as answer
if p_result.NofContours > 0
for idx_xy = 1:p_result.Contour(1).Vertex.Length
    P(idx_xy,1) = p_result.Contour(1).Vertex(idx_xy).X;
    P(idx_xy,2) = p_result.Contour(1).Vertex(idx_xy).Y;
end
else
    P = [];
end

end
