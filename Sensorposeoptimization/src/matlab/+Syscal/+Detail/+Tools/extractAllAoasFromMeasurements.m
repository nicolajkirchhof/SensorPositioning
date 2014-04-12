function [ aoas, positions ] = extractAllAoasFromMeasurements( sobjs, pixval_normalized, refs, debug )
%EXTRACTAOAFROMLIKELIHOOD Summary of this function goes here
%   Detailed explanation goes here
if nargin < 4
    debug = false;
end

aoas = {};
positions = {};
for idx_sensor = 1:numel(sobjs)
    for idx_measure = 1:size(pixval_normalized, 2)
        pixval = pixval_normalized{idx_sensor, idx_measure};
        if ~isempty(pixval)
            sobj = sobjs{idx_sensor};
            ref = refs(idx_measure, :);
            [aoa, pos] = Syscal.Detail.Tools.ExtractAoaFromLikelihood(sobj, pixval, ref);
            aoas{idx_sensor, idx_measure} = aoa;
            positions{idx_sensor, idx_measure} = pos;
        end
    end
end





