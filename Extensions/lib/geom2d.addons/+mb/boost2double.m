function [ bpoly_d ] = boost2double( bpoly )
%BOOST2DOUBLE returns boost array as a double
if ~iscell(bpoly)
    bpoly_d = double(bpoly);
    return;
end

bpoly_d = {};
for idp = 1:numel(bpoly)
    if iscell(bpoly{idp})
        tmp = mb.boost2double(bpoly{idp});
        bpoly_d(end+1:end+numel(tmp)) = tmp(:);
    else
        bpoly_d{end+1} = double(bpoly{idp});
    end
end   
