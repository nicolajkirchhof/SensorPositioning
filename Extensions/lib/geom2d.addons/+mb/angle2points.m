function thetas = angle2points(varargin)
%ANGLE2POINTS Summary of this function goes here
%   Detailed explanation goes here
%input are edges
if nargin == 1
    thetas = angle2Points(double(varargin{1}(:,1:2)), double(varargin{1}(:,3:4)));
else
    thetas = angle2Points(double(varargin{1})', double(varargin{2})');
end

end

