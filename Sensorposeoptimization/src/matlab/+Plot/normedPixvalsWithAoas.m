function normedPixvalsWithAoas(sobjs, aoas, pixel_values_normalized, references, idx_measure, axis_limits)
if nargin < 5
    axis_limits = [-1 6 -1 6];
end

% for idx_measure = 1:size(pixel_values_normalized, 2)
Plot.AllSensorAoas(sobjs, aoas, references, idx_measure, axis_limits);
reference = references(idx_measure, :);
Plot.NormalizedPixval2d(sobjs, pixel_values_normalized, idx_measure, reference, axis_limits)
% end