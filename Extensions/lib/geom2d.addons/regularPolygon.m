function [ poly ] = regularPolygon( sides )
%REGULARPOLYGON creates a regular polygon around the zero coordinate with radius 0, use offset and
% scale to transform
%%
degrees=2*pi/sides;
theta=0:degrees:2*pi;
radius=1;%ones(1,numel(theta));
[x y] = pol2cart(theta,radius);
poly = [x(1:sides)', y(1:sides)'];

% for (i = 0; i < n; i++) {
%   printf('%f %f\n',x + r * Math.cos(2 * Math.PI * i / n), y + r * Math.sin(2 * Math.PI * i / n));
% }
% 
% end

