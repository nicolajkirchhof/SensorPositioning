%%
% import Figures.*;
clearvars -except all_eval*
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
    Z{cnt} = 1 - (2 * a_sq .* b_sq ) ./ ( dmax^2 * sqrt( (b-a+c) .* (a-b+c) .* (a+b-c) .* (a+b+c) ) );
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
clf;
cla;
hold on;
axis equal;
% C = {};
% cnt = 1;
range = 0.1:0.1:0.9;
cmap = flipud([range', range', range']);
colormap(cmap);
for contourlevel = range
    contour(X,Y,Z{cnt}, contourlevel) %, 'color', (0.9-contourlevel)*[1 1 1]); %,  'ShowText','on', 'LabelSpacing', 250);
    %     cnt = cnt + 1;
end
%%%
dm = (x2-x1);
% title(sprintf('Polygon contours at %m', dm));
xlabel('$[m]$');
ylabel('$[m]$');
% axis equal;
ylim([3 17.5]);
xlim([1.5 13]);

set(gca,'YDir','normal', 'XTick', 3:2:11, 'YTick', 4:2:16);
plot(x1, y1, 'ok', 'markerfacecolor', [0 0 0]);
plot((x1+distances(cnt)), y1, 'ok', 'markerfacecolor', [0 0 0]);
%%%
xt = 7;
idxt = find(X(1,:)==xt, 1, 'first');
%%%
for contourlevel = 0.4:0.1:0.9
    %%
    txt_level = sprintf('\\footnotesize $>%g$', contourlevel);
    yt_top = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'last'),idxt);
    yt_bottom = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'first'), idxt);
    text(xt, yt_top-0.05, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'interpreter', 'none');
    text(xt, yt_bottom+0.05, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
    
end
%%%
filename = 'QScKellyContours_2m.tex';
% Figures.makeFigure(filename);
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '10cm',...
    'width', '11cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
%
find_and_replace(full_filename,'xlabel={\$\[m\]\$},', 'xlabel={$[m]$},\nevery axis x label/.style={at={(current axis.south east)},anchor=north east },');
find_and_replace(full_filename, 'ylabel={\$\[m\]\$}', 'ylabel={$[m]$},\nevery axis y label/.style={at={(current axis.north west)},anchor=north east}');
%
find_and_replace(full_filename, 'colormap=\{mymap\}\{\[1pt\] rgb\(0pt\)=\(0.9,0.9,0.9\); rgb\(8pt\)=\(0.1,0.1,0.1\)\},', '%');
Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);

%%
cnt = 4;
% figure; hold on;
cla; hold on;
range = 0.1:0.1:0.9;
cmap = flipud([range', range', range']);
colormap(cmap);
for contourlevel = 0.1:0.1:0.9
    contour(X,Y,Z{cnt}, contourlevel);%, 'color', (1-contourlevel)*[1 1 1]); %,  'ShowText','on', 'LabelSpacing', 250);
    %     contour(X,Y,Z{cnt}, contourlevel, 'color', (1-contourlevel)*[1 1 1], 'ShowText','on', 'LabelSpacing', 250);
end
% dm = (x2-x1);
dm = distances(cnt);
% title(sprintf('Polygon contours at %m', dm));
xlabel('$[m]$');
ylabel('$[m]$');
axis equal;
ylim([2, 18]);
xlim([2.5, 15.5]);
set(gca,'YDir','normal', 'XTick', 3:2:13, 'YTick', 4:2:16);
plot(x1, y1, 'ok', 'markerfacecolor', [0 0 0]);
plot((x1+distances(cnt)), y1, 'ok', 'markerfacecolor', [0 0 0]);
%%% Plot Symmetry lines and text
pt_sym = [11, 12;
    7, 12;
    7, 8;
    11, 8];
% alignment = {'bottom', 'bottom', 'top', 'top'};
phiBoffset= [180, 180, 0, 0];
phiAoffset= [0, 0, 180, 180];
for idpt = 1
    %%
    plot(pt_sym(idpt, 1), pt_sym(idpt, 2), 'k+', 'markersize', 10, 'linewidth', 2);
    edgeA = [[x1, y1], pt_sym(idpt, :)];
    lineA = createLine(edgeA(1:2), edgeA(3:4));
    phiA = rad2deg(lineAngle(lineA))+phiAoffset(idpt);
    ptA = polarPoint(pointOnLine(lineA, edgeLength(edgeA)/2.1), 0.2, deg2rad(phiA+90)) ;
    drawEdge(edgeA, 'color', [0 0 0], 'linewidth', 2, 'linestyle', '--');
    text(ptA(1), ptA(2), ['\footnotesize $a_' num2str(idpt) '$'], 'Rotation', phiA, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
    %%
    edgeB = [[x1+dm, y2], pt_sym(idpt, :)];
    lineB = createLine(edgeB(1:2), edgeB(3:4));
    phiB = rad2deg(lineAngle(lineB))+phiBoffset(idpt);
    ptB = polarPoint(pointOnLine(lineB, edgeLength(edgeB)/1.8),0.2, deg2rad(phiB+90)) ;
    drawEdge(edgeB , 'color', [0 0 0], 'linewidth', 2, 'linestyle', ':');
    text(ptB(1), ptB(2), ['\footnotesize $b_' num2str(idpt) '$'], 'Rotation', phiB,'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
    
    ptA_txt = polarPoint(pt_sym(idpt, :), 0.6, deg2rad(phiBoffset(idpt)-90)) ;
    text(ptA_txt(1), ptA_txt(2), ['\footnotesize $p_' num2str(idpt) '$'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    
end
for idpt = 2
    %%
    plot(pt_sym(idpt, 1), pt_sym(idpt, 2), 'k+', 'markersize', 10, 'linewidth', 2);
    edgeA = [[x1, y1], pt_sym(idpt, :)];
    lineA = createLine(edgeA(1:2), edgeA(3:4));
    phiA = rad2deg(lineAngle(lineA))+phiAoffset(idpt);
    ptA = polarPoint(pointOnLine(lineA, edgeLength(edgeA)/1.8), 0.2, deg2rad(phiA+90)) ;
    drawEdge(edgeA, 'color', [0 0 0], 'linewidth', 2, 'linestyle', '--');
    text(ptA(1), ptA(2), ['\footnotesize $a_' num2str(idpt) '$'], 'Rotation', phiA, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
    %%
    edgeB = [[x1+dm, y2], pt_sym(idpt, :)];
    lineB = createLine(edgeB(1:2), edgeB(3:4));
    phiB = rad2deg(lineAngle(lineB))+phiBoffset(idpt);
    ptB = polarPoint(pointOnLine(lineB, edgeLength(edgeB)/2.1),0.2, deg2rad(phiB+90)) ;
    drawEdge(edgeB , 'color', [0 0 0], 'linewidth', 2, 'linestyle', ':');
    text(ptB(1), ptB(2), ['\footnotesize $b_' num2str(idpt) '$'], 'Rotation', phiB,'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
    
    ptA_txt = polarPoint(pt_sym(idpt, :), 0.6, deg2rad(phiBoffset(idpt)-90)) ;
    text(ptA_txt(1), ptA_txt(2), ['$\footnotesize p_' num2str(idpt) '$'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    
end
for idpt = 3
    %%
    plot(pt_sym(idpt, 1), pt_sym(idpt, 2), 'k+', 'markersize', 10, 'linewidth', 2);
    edgeA = [[x1, y1], pt_sym(idpt, :)];
    lineA = createLine(edgeA(1:2), edgeA(3:4));
    phiA = rad2deg(lineAngle(lineA))+phiAoffset(idpt);
    ptA = polarPoint(pointOnLine(lineA, edgeLength(edgeA)/1.8), 0.2, deg2rad(phiA+90)) ;
    drawEdge(edgeA, 'color', [0 0 0], 'linewidth', 2, 'linestyle', '--');
    text(ptA(1), ptA(2), ['\footnotesize $a_' num2str(idpt) '$'], 'Rotation', phiA, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
    %%
    edgeB = [[x1+dm, y2], pt_sym(idpt, :)];
    lineB = createLine(edgeB(1:2), edgeB(3:4));
    phiB = rad2deg(lineAngle(lineB))+phiBoffset(idpt);
    ptB = polarPoint(pointOnLine(lineB, edgeLength(edgeB)/2.1),0.2, deg2rad(phiB+90)) ;
    drawEdge(edgeB , 'color', [0 0 0], 'linewidth', 2, 'linestyle', ':');
    text(ptB(1), ptB(2), ['\footnotesize $b_' num2str(idpt) '$'], 'Rotation', phiB,'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
    
    ptA_txt = polarPoint(pt_sym(idpt, :), 0.6, deg2rad(phiBoffset(idpt)-90)) ;
    text(ptA_txt(1), ptA_txt(2), ['\footnotesize $p_' num2str(idpt) '$'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    
end
for idpt = 4
    %%
    plot(pt_sym(idpt, 1), pt_sym(idpt, 2), 'k+', 'markersize', 10, 'linewidth', 2);
    edgeA = [[x1, y1], pt_sym(idpt, :)];
    lineA = createLine(edgeA(1:2), edgeA(3:4));
    phiA = rad2deg(lineAngle(lineA))+phiAoffset(idpt);
    ptA = polarPoint(pointOnLine(lineA, edgeLength(edgeA)/2.1), 0.2, deg2rad(phiA+90)) ;
    drawEdge(edgeA, 'color', [0 0 0], 'linewidth', 2, 'linestyle', '--');
    text(ptA(1), ptA(2), ['\footnotesize $a_' num2str(idpt) '$'], 'Rotation', phiA, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
    %%
    edgeB = [[x1+dm, y2], pt_sym(idpt, :)];
    lineB = createLine(edgeB(1:2), edgeB(3:4));
    phiB = rad2deg(lineAngle(lineB))+phiBoffset(idpt);
    ptB = polarPoint(pointOnLine(lineB, edgeLength(edgeB)/1.8),0.2, deg2rad(phiB+90)) ;
    drawEdge(edgeB , 'color', [0 0 0], 'linewidth', 2, 'linestyle', ':');
    text(ptB(1), ptB(2), ['\footnotesize $b_' num2str(idpt) '$'], 'Rotation', phiB,'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
    
    ptA_txt = polarPoint(pt_sym(idpt, :), 0.6, deg2rad(phiBoffset(idpt)-90)) ;
    text(ptA_txt(1), ptA_txt(2), ['\footnotesize $p_' num2str(idpt) '$'], 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
    
end

drawEdge([x1, y1], [x1+dm, y2], 'color', [0 0 0], 'linewidth', 2);
text(9.1, 10.3, '\footnotesize $c$', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
line(xlim, [10, 10], 'color', [0 0 0], 'linewidth', 0.5, 'linestyle', '-.');
line([9, 9],ylim, 'color', [0 0 0], 'linewidth', 0.5, 'linestyle', '-.');

%%% Plot contour descriptions
contourlevel = 0.9;
xt = 5.1;
idxt = find(X(1,:)==xt, 1, 'first');
txt_level = sprintf('\\footnotesize $>%g$', contourlevel);
yt_top = 10.7;
yt_bottom = 9.3;
text(xt, yt_top, txt_level, 'Rotation', 45, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'interpreter', 'none');
text(xt, yt_bottom, txt_level, 'Rotation', 495, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'interpreter', 'none');
xt = 13;
txt_level = sprintf('\\footnotesize $>%g$', contourlevel);
% yt_top = 11;
% yt_bottom = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'first'), idxt);
text(xt, yt_top, txt_level, 'Rotation', 315, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
text(xt, yt_bottom, txt_level, 'Rotation', 225, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
%%%
contourlevel = 0.8;
xt = 6;
idxt = find(X(1,:)==xt, 1, 'first');
txt_level = sprintf('\\footnotesize $>%g$', contourlevel);
yt_top = 12;
yt_bottom = 8;
text(xt, yt_top, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'interpreter', 'none');
text(xt, yt_bottom, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'interpreter', 'none');
xt = 12;
txt_level = sprintf('\\footnotesize $>%g$', contourlevel);
% yt_top = 11;
% yt_bottom = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'first'), idxt);
text(xt, yt_top, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'interpreter', 'none');
text(xt, yt_bottom, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'interpreter', 'none');

%%%
xt = 9.0;
idxt = find(X(1,:)==xt, 1, 'first');
%%%
for contourlevel = 0.4:0.1:0.7
    %%
    txt_level = sprintf('\\footnotesize $>%g$', contourlevel);
    yt_top = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'last'),idxt);
    yt_bottom = Y(find(Z{cnt}(:,idxt)>contourlevel, 1, 'first'), idxt);
    text(xt+0.2, yt_top-0.05, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'interpreter', 'none');
    text(xt+0.2, yt_bottom+0.05, txt_level, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'interpreter', 'none');
end%     matlab2tikz(sprintf('export/PolygonEvaluationSzenario_%dm.tikz', dm), 'parseStrings', false);
%%%
filename = 'QScKellyContours_8m.tex';

full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '10cm',...
    'width', '11cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
find_and_replace(full_filename,'xlabel={\$\[m\]\$},', 'xlabel={[$m$]},\nevery axis x label/.style={at={(current axis.south east)},anchor=north east },');
find_and_replace(full_filename, 'ylabel={\$\[m\]\$}', 'ylabel={[$m$]},\nevery axis y label/.style={at={(current axis.north west)},anchor=north east}');
Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);


%%
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
Figures.makeFigure('QScKellyContours_14m');
% matlab2tikz('export/QScKellyContours_14m.tikz', 'parseStrings', false,...
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '8cm',...
% ...    'height', '5cm',
% 'extraAxisOptions',{'y post scale=1'});