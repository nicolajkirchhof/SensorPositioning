function [ fpoly, ids ] = flattenPolygon( bpoly )
%BOOST2VISILIBITY Summary of this function goes here
%   Detailed explanation goes here
%extract all rings
if ~iscell(bpoly)
    fpoly = {bpoly};
    ids = [];
    return;
end

fpoly = {};
ids = {(1:numel(bpoly))'};
for idp = 1:numel(bpoly)
    if iscell(bpoly{idp})
        [tmp, ids0] = mb.flattenPolygon(bpoly{idp});
        fpoly(end+1:end+numel(tmp)) = tmp(:);
        % remove index if empty, otherwise append
        if ~isempty(ids0{1})
            ids(end+1:end+numel(ids0)) = ids0;
        else
            ids{1} = ids{1}([1:idp-1,idp+1:end]);
        end
    else
        fpoly{end+1} = bpoly{idp};
    end
end   



