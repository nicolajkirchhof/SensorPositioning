function [ poly ] = correctPolygon2Geom( poly )
%CORRECTPOLYGON Summary of this function goes here
%   Detailed explanation goes here
fun_check_poly = @(poly) size(poly{1}, 1)==2;
fun_check_ring = @(ring) size(ring,1)==2;
if ~iscell(poly)
    if fun_check_ring(poly)
        poly = mb.boost2visilibity(poly);
    end
    poly = {poly};
elseif iscell(poly{1})
    % multi polygon
    flt = cellfun(fun_check_poly, poly);
    poly(flt) = mb.boost2visilibity(poly(flt));
else
%     if ~any(cellfun(fun_check_ring, poly))
flt = cellfun(fun_check_ring, poly);
        poly(flt) = mb.boost2visilibity(poly(flt));
%     end
end
        
    

end