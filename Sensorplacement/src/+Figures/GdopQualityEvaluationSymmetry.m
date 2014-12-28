% function  q = GdopQualityEvaluationSymmetry( x, y, x1, y1, x2, y2, dmax )

% q = 0;
% if (1 >= 1/dmax*((x - x1)^2 + (y - y1)^2)^(1/2)) ||...
%         (1 >= 1/dmax*((x - x2)^2 + (y - y2)^2)^(1/2))


q =@(a_sq, b_sq, a, b, c, dmax)  1 - ( a_sq .* b_sq ) / ( dmax^2 * sqrt( (b-a+c) * (a-b+c) * (a+b-c) * (a+b+c) ) );
% end
%qs = @( x, y, x1, y1, x2, y2, dmax ) sqrt((((x-x1).^2+(x-x2).^2-(x1-x2).^2+(y-y1).^2+(y-y2).^2-(y1-y2).^2).^2.*...
%   (-1.0/4.0))/(((x-x1).^2+(y-y1).^2).*((x-x2).^2+(y-y2).^2))+1.0)./((((x-x1).^2+(y-y1).^2).*((x-x2).^2+(y-y2).^2))/dmax+1.0);

% dn = @( x, y, xi, yi, dmax) min(sqrt((x-xi)^2+(y-yi)^2)/dmax, 1);
% qs = @( x, y, x1, y1, x2, y2, dmax ) max(1-(dn(x,y,x1,y1,dmax) * dn(x,y,x2,y2,dmax) ), 0);
% qs = @( x, y, x1, y1, x2, y2, dmax ) max([min([sqrt(abs(x-x1)^2+abs(y-y1)^2),1.0])*min([sqrt(abs(x-x2)^2+abs(y-y2)^2),1.0])*1.0/sqrt(((abs(x-x1)^2+abs(x-x2)^2-abs(x1-x2)^2+abs(y-y1)^2+abs(y-y2)^2-abs(y1-y2)^2)^2*(-1.0/4.0))/((abs(x-x1)^2+abs(y-y1)^2)*(abs(x-x2)^2+abs(y-y2)^2))+1.0)*(-1.0/2.0)+1.0,0.0]);

%% plot contour
% dmax = 100^4/5;

% subs(Qs, x1 = 100, y1 = 100, x2 = 175, y2 = 100, dmax = 100^4/5);
%%
% import Figures.*;
x1 = 5000;
y1 = 10000;
y2 = 10000;
dmax = 10000;
%%
for x2 = [2000, 6000, 10000]
    %%
    x = 0:10:20000;
    y = 0:10:20000;
    [X, Y] = meshgrid(x, y);
%     Z = zeros(size(X));
    %%
    for i = 1:numel(X)
        %%
        a_sq = (X - x1).^2 + (Y - y1).^2;
        a = sqrt(a_sq);
        b_sq = (X - x2).^2 + (Y - y2).^2;
        b = sqrt(b_sq);
        c_sq = (x1 - x2).^2 + (y1 - y2).^2;
        c = sqrt(c_sq);
        Z = 1 - ( a_sq .* b_sq ) ./ ( dmax^2 * sqrt( (b-a+c) .* (a-b+c) .* (a+b-c) .* (a+b+c) ) );
        
        a_flt = dmax^2 < a_sq;
        b_flt = dmax^2 < b_sq;
        Z(a_flt|b_flt) = 0;
        %%
        
    end
    %%
    figure;
    contour(Z, 0:0.1:1);
    title(sprintf('Distance is %dcm', x2-x1));
end
