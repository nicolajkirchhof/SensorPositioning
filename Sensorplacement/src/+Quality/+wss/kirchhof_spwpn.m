function [ output_args ] = kirchhof_spwpn( input_args )
%KIRCHHOF_SPWPN Summary of this function goes here
%   Detailed explanation goes here


    %%%
    a_sq = (X - x1).^2 + (Y - y1).^2;
    a = sqrt(a_sq);
    b_sq = (X - x2).^2 + (Y - y2).^2;
    b = sqrt(b_sq);
    c_sq = (x1 - x2).^2 + (y1 - y2).^2;
    c = sqrt(c_sq);
    Z = 1 - (2 * a_sq .* b_sq ) ./ ( dmax^2 * sqrt( (b-a+c) .* (a-b+c) .* (a+b-c) .* (a+b+c) ) );
    Z = real(Z);
    Z(1001, :) = 0;
    Z(Z<0) = 0;
    
    a_flt = dmax^2 < a_sq;
    b_flt = dmax^2 < b_sq;
    Z(a_flt|b_flt) = 0;

end

