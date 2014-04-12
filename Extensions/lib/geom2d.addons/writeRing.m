function poly_txt = writeRing( poly, filename )
%WRITE_ENVIRONMENT Summary of this function goes here
%   Detailed explanation goes here
poly = mb.correctPolygon(poly);
poly_txt = sprintf('%d %d\n', poly(:,1:end-1));
if nargin > 1
    fid = fopen(filename, 'w');
    fprintf(fid, '%s', poly_txt);
    fclose(fid);
end
end

