function [ vpoly ] = boost2visilibity( bpoly )
%BOOST2VISILIBITY Summary of this function goes here
%   Detailed explanation goes here
%extract all rings
if ~iscell(bpoly)
    if size(bpoly, 2) == 2
        vpoly = bpoly;
    else
        vpoly = double(bpoly(:, 1:end-1)');
    end
    return;
end

vpoly = {};
for idp = 1:numel(bpoly)
    tmp = mb.boost2visilibity(bpoly{idp});
    if ~iscell(tmp); tmp = {tmp}; end;
%     if iscell(bpoly{idp})
        vpoly(end+1:end+numel(tmp)) = tmp(:);
%     else
%         vpoly{end+1} = double(bpoly{idp}(:, 1:end-1)');
%     end
end   



