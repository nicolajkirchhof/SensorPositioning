function [ vpolys_out ] = select_holes( vpolys )
%SELECT_BOUNDARIES Summary of this function goes here
%   Detailed explanation goes here
vpolys_out = {};
for idvp = 1:numel(vpolys)
    if polygonArea(vpolys{idvp})<=0
        vpolys_out{end+1} = vpolys{idvp};
    end
end
        

end
