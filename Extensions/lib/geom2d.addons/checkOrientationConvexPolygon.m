dirname = 'res/env/convex_polygons/';
conv_poly_files = dir(dirname);
%%
for idp = 3:numel(conv_poly_files)
    filename = [dirname conv_poly_files(idp).name];
    poly = load_environment_file(filename);
%     ccw = polygonIsCounterClockwise(double(poly{1}));
    ccw = -1;
    if ccw < 0
        figure,
        drawPolygon(poly);
        mb.numberPolygon(poly);
    end
end
    