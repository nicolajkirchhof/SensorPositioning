function polygon_wkt_export(bpoly, fid)
fprintf(fid, 'POLYGON(');
if ~iscell(bpoly)
    write_wkt_ring(bpoly, fid);
else
    for idr = 1:numel(bpoly)
        write_wkt_ring(ply, fid);
        fprintf(fid, ',');
    end
end
fprintf(fid, ')\n');

function write_wkt_ring(ring, fid)
fprintf(fid, '(');
switch class(ring)
    case 'double'
        fprintf(fid, '%8.20f %8.20f,', ring);
    case 'int64'
        fprintf(fid, '%d %d,', ring);
end
fprintf(fid, ')');
