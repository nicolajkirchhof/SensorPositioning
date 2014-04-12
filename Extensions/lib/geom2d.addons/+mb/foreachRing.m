function outpoly = foreachRing( inpoly, fcn )
%FOREACHRING Summary of this function goes here
%   Detailed explanation goes here
outpoly = {};
for idp = 1:numel(inpoly)
    if iscell(inpoly{idp})
        outpoly{idp} = mb.foreachRing(inpoly{idp}, fcn);
    else
        outpoly{idp} = fcn(inpoly{idp});
    end
end

end

