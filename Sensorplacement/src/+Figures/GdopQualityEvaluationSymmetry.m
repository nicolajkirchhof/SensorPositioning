% function  q = GdopQualityEvaluationSymmetry( x, y, x1, y1, x2, y2, dmax )

% q = 0;
% if (1 >= 1/dmax*((x - x1)^2 + (y - y1)^2)^(1/2)) ||...
%         (1 >= 1/dmax*((x - x2)^2 + (y - y2)^2)^(1/2))

% q =@(a_sq, b_sq, a, b, c, dmax)  1 - ( a_sq .* b_sq ) / ( dmax^2 * sqrt( (b-a+c) * (a-b+c) * (a+b-c) * (a+b+c) ) );
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
clear all;
x1 = 5;
y1 = 10;
y2 = 10;
dmax = 10;
distances = (2:2:18);
Z = cell(numel(distances), 1);
cnt = 1;
%%%%
for x2 = x1+distances
    %%
    x = 0:0.01:30;
    y = 0:0.01:20;
    [X, Y] = meshgrid(x, y);
    %     Z = zeros(size(X));
    %%
    %     for i = 1:numel(X)
    %%
    a_sq = (X - x1).^2 + (Y - y1).^2;
    a = sqrt(a_sq);
    b_sq = (X - x2).^2 + (Y - y2).^2;
    b = sqrt(b_sq);
    c_sq = (x1 - x2).^2 + (y1 - y2).^2;
    c = sqrt(c_sq);
    Z{cnt} = 1 - ( a_sq .* b_sq ) ./ ( dmax^2 * sqrt( (b-a+c) .* (a-b+c) .* (a+b-c) .* (a+b+c) ) );
    Z{cnt} = real(Z{cnt});
    Z{cnt}(1001, :) = 0;
    Z{cnt}(Z{cnt}<0) = 0;
    
    a_flt = dmax^2 < a_sq;
    b_flt = dmax^2 < b_sq;
    Z{cnt}(a_flt|b_flt) = 0;
    %%
    cnt = cnt+1;
end

%%
cnt = 2;
% figure; hold on;
cla; hold on;
for contourlevel = 0.1:0.1:0.9
    contour(X,Y,Z{cnt}, contourlevel, 'color', (0.9-contourlevel)*[1 1 1]); %,  'ShowText','on', 'LabelSpacing', 250);
end
dm = (x2-x1);
% title(sprintf('Polygon contours at %m', dm));
xlabel('$[m]$');
ylabel('$[m]$');
axis equal;
ylim([1, 19]);
xlim([0.5, 13.5]);
set(gca,'YDir','normal');
% set(gca, 'XTickLabel', num2str(str2num(get(gca, 'XTickLabel'))/100));
% set(gca, 'YTickLabel', num2str(str2num(get(gca, 'YTickLabel'))/100));
plot(x1, y1, 'ok', 'markerfacecolor', [0 0 0]);
plot((x1+distances(cnt)), y1, 'ok', 'markerfacecolor', [0 0 0]);
%%%
xt = 7;
idxt = find(X(1,:)==xt, 1, 'first');
%%%
for contourlevel = 0.4:0.1:0.9
    %%
    txt_level = sprintf('$>%g$', contourlevel);
    yt_top = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'last'),idxt);
    yt_bottom = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'first'), idxt);
    text(xt, yt_top-0.05, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    text(xt, yt_bottom+0.05, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    
end
matlab2tikz('export/QScKellyContours_2m.tikz', 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '8cm',...
...%     'height', '5cm',... 
    'extraAxisOptions',{'y post scale=1'});
%%%
cnt = 4;
% figure; hold on;
cla; hold on;
for contourlevel = 0.1:0.1:0.9
    contour(X,Y,Z{cnt}, contourlevel, 'color', (1-contourlevel)*[1 1 1]); %,  'ShowText','on', 'LabelSpacing', 250);
    %     contour(X,Y,Z{cnt}, contourlevel, 'color', (1-contourlevel)*[1 1 1], 'ShowText','on', 'LabelSpacing', 250);
end
dm = (x2-x1);
% title(sprintf('Polygon contours at %m', dm));
xlabel('$[m]$');
ylabel('$[m]$');
axis equal;
ylim([0.5, 19.5]);
xlim([2.5, 15.5]);
set(gca,'YDir','normal');
plot(x1, y1, 'ok', 'markerfacecolor', [0 0 0]);
plot((x1+distances(cnt)), y1, 'ok', 'markerfacecolor', [0 0 0]);
%%%
contourlevel = 0.9;
xt = 5.5;
idxt = find(X(1,:)==xt, 1, 'first');
txt_level = sprintf('$>%g$', contourlevel);
yt_top = 11.5;
yt_bottom = 8.5;
text(xt, yt_top, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
text(xt, yt_bottom, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
xt = 12.5;
txt_level = sprintf('$>%g$', contourlevel);
% yt_top = 11;
% yt_bottom = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'first'), idxt);
text(xt, yt_top, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
text(xt, yt_bottom, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
%%%
xt = (x2-x1)/2;
idxt = find(X(1,:)==xt, 1, 'first');
%%%
for contourlevel = 0.4:0.1:0.8
    %%
    txt_level = sprintf('$>%g$', contourlevel);
    yt_top = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'last'),idxt);
    yt_bottom = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'first'), idxt);
    text(xt, yt_top-0.05, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
    text(xt, yt_bottom+0.05, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end%     matlab2tikz(sprintf('export/PolygonEvaluationSzenario_%dm.tikz', dm), 'parseStrings', false);
matlab2tikz('export/QScKellyContours_8m.tikz', 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '8cm',...
...    'height', '5cm', 
    'extraAxisOptions',{'y post scale=1'});
%%%
cnt = 7;
% figure; hold on;
    cla; hold on;
for contourlevel = 0.1:0.1:0.9
    contour(X,Y,Z{cnt}, contourlevel, 'color', (1-contourlevel)*[1 1 1]); %,  'ShowText','on', 'LabelSpacing', 250);
%         contour(X,Y,Z{cnt}, contourlevel, 'color', (1-contourlevel)*[1 1 1], 'ShowText','on', 'LabelSpacing', 250);
end
dm = (x2-x1);
% title(sprintf('Polygon contours at %m', dm));
xlabel('$[m]$');
ylabel('$[m]$');
axis equal;
ylim([2, 18]);
xlim([4, 20]);
set(gca,'YDir','normal');
plot(x1, y1, 'ok', 'markerfacecolor', [0 0 0]);
plot((x1+distances(cnt)), y1, 'ok', 'markerfacecolor', [0 0 0]);
%%%
xt = 12;
idxt = find(X(1,:)==xt, 1, 'first');
ymid = round(numel(Z{cnt}(:,idxt))/2);
%%%
for contourlevel = [0.4, 0.5, 0.6]
    %%
    txt_level = sprintf('$>%g$', contourlevel);
    yt_top = Y(find(Z{cnt}(ymid:end,idxt)>contourlevel, 1, 'first')+ymid,idxt);
    yt_bottom = Y(find(Z{cnt}(1:ymid,idxt)>contourlevel, 1, 'last'), idxt);
    text(xt, yt_top-0.1, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
    text(xt, yt_bottom+0.1, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top');
end%     matlab2tikz(sprintf('export/PolygonEvaluationSzenario_%dm.tikz', dm), 'parseStrings', false);
contourlevel = 0.5;
txt_level = sprintf('$>%g$', contourlevel);
yt_top = 16;
yt_bottom = 4;
text(xt, yt_top, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(xt, yt_bottom, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');

matlab2tikz('export/QScKellyContours_14m.tikz', 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '8cm',...
...    'height', '5cm', 
'extraAxisOptions',{'y post scale=1'});