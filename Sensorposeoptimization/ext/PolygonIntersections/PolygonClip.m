function P = PolygonClip( P1, P2, Type )
    if isempty(which('GpcWrapper.Polygon'))
        p = mfilename('fullpath');
        p = fileparts(p);
        NET.addAssembly([p '/GpcWrapper.dll']);
    end
    P = [];
    switch Type
        case 0
            Gpc_Type = GpcWrapper.GpcOperation.Difference;
        case 1
            Gpc_Type = GpcWrapper.GpcOperation.Intersection;
        case 2
            Gpc_Type = GpcWrapper.GpcOperation.XOr;
        case 3
            Gpc_Type = GpcWrapper.GpcOperation.Union;
    end
           
    
    poly1 = GpcWrapper.Polygon;
    poly2 = GpcWrapper.Polygon;
    
    for idx_P = 1:numel(P1) 
        vl_tmp = GpcWrapper.VertexList(double(single(P1(idx_P).x)), double(single(P1(idx_P).y)));
        poly1.AddContour(vl_tmp, logical(P1(idx_P).hole));
    end
    for idx_P = 1:numel(P2) 
        vl_tmp = GpcWrapper.VertexList(double(single(P2(idx_P).x)), double(single(P2(idx_P).y)));
        poly2.AddContour(vl_tmp, logical(P2(idx_P).hole));
    end
    
    p_result = poly1.Clip(Gpc_Type, poly2);
        
    for idx_contour = 1:p_result.NofContours
        P(idx_contour).hole = p_result.ContourIsHole(idx_contour);
        for idx_xy = 1:p_result.Contour(idx_contour).Vertex.Length
            P(idx_contour).x(idx_xy) = p_result.Contour(idx_contour).Vertex(idx_xy).X;
            P(idx_contour).y(idx_xy) = p_result.Contour(idx_contour).Vertex(idx_xy).Y;
        end
    end
end
