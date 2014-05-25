function plot_uncertainty(uc, t, varargin)
%PLOT_UNCERTAINTY Summary of this function goes here
%   Detailed explanation goes here
for i = 1:nargin-2
    [in_circ, out_circ] = calc_uncertaintyCircles(uc, t, varargin{i});
    drawCircle(in_circ);
    hold on;
    drawCircle(out_circ);
end 






