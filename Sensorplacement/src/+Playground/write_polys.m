

%% regular polygons
polys = {}; for ids = 3:10; polys{ids-2} = regularPolygon(ids)*2500+2500; figure, axis equal, drawPolygon(polys{ids-2}); end
for idp = 1:numel(polys)
    num_pts = size(polys{idp}, 1);
    fid = fopen(sprintf('res/env/simple_poly%d_%d.environment', num_pts, 0), 'w');
    poly_comment = sprintf('// %d sided regular polygon ', num_pts);
    poly_txt = writeRing(polys{idp});
    fprintf(fid, '%s\n%s', poly_comment, poly_txt);
    fclose(fid);
%     mb.writeRing(, , polys{idp});
end

%% random polygons
close all;
tmp_polys = {}; 
num_sides = 10;
for i = 1:20; tmp_polys{i} = 5000*randomPolygon(num_sides, 'shuffle'); end
for i = 1:numel(tmp_polys); figure, axis equal, hold on, drawPolygon(tmp_polys{i}), mb.numberPolygon(tmp_polys{i}); end
%%

polys = tmp_polys([19,18,13,5,17,7,15,3]);
%%
offset = 0;
for idp = 1:numel(polys)
    num_pts = size(polys{idp}, 1);
    fid = fopen(sprintf('res/env/convex_polygons/sides%d_nr%d.environment', num_pts, idp+offset), 'w');
    poly_comment = sprintf('// %d sided random convex polygon ', num_pts);
    poly_txt = writeRing(polys{idp});
    fprintf(fid, '%s\n%s', poly_comment, poly_txt);
    fclose(fid);
%     mb.writeRing(, , polys{idp});
end