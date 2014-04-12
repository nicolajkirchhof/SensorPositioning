function [ poly ] = correctPolygon( poly )
%CORRECTPOLYGON Summary of this function goes here
%   Detailed explanation goes here
fun_check_ring = @(ring) size(ring,1)==2;
if ~iscell(poly)
    if ~fun_check_ring(poly)
        poly = mb.visilibity2boost(poly);
    end
    poly = {poly};
else
%     if ~any(cellfun(fun_check_ring, poly))
flt = ~cellfun(fun_check_ring, poly);
        poly(flt) = mb.visilibity2boost(poly(flt));
%     end
end
        
    

end

