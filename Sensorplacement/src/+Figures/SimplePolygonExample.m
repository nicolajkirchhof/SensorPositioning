close all;
clearvars -except all_eval*
%%
cla;
hold on;
axis equal
xlim([-100 1100]);
ylim([-100 1100]);
poly = [0 1000 1000 500 500  0    0;
        0 0    500  500 800 800 0];

hole = [300 300 400 400 100 100 300;
        200 100 100 300 300 200 200];
    
poly = bpolyclip(poly, hole, 0, 1);       
mb.drawPolygon(poly, 'color', 'k', 'linewidth', 3);
mb.drawPoint(poly{1}{1}(:,[1,2,3,5,6]), 'color', 'k', 'markersize', 8, 'markerfacecolor', 'k');
mb.drawPoint(poly{1}{2}(:,[2,3,4,5,6]), 'color', 'k', 'markersize', 8, 'markerfacecolor', 'k');
gray = 0.6;
mb.drawPoint(poly{1}{2}(:,[1]), 'color', gray*ones(1,3), 'markersize', 8, 'markerfacecolor', gray*ones(1,3));
mb.drawPoint(poly{1}{1}(:,[4]), 'color', gray*ones(1,3), 'markersize', 8, 'markerfacecolor', gray*ones(1,3));

text(600, 300, '$r_1$');
text(200, 250, '$h_1$');

text(-80, -40, '$p_1$');
text(480, -40, '$e_6$');
text(-80, 400, '$e_1$');
text(-80, 840, '$p_2$');
text(530, 840, '$p_3$');
text(530, 540, '$p_4$');
text(1030, 540, '$p_5$');
text(1030, -40, '$p_6$');
text(230, 840, '$e_2$');
text(520, 650, '$e_3$');
text(750, 540, '$e_4$');
text(1020, 250, '$e_5$');

text(230, 160, '$p_1$');
text(30, 160, '$p_6$');
text(30, 340, '$p_5$');
text(430, 340, '$p_4$');
text(430, 60, '$p_3$');
text(230, 60, '$p_2$');
axis off;
%%
% Figures.makeFigure('SimplePolygonExample');
filename = 'SimplePolygonExample.tex';
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
...    'height', '7cm',...
    'width', '11cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
% Figures.compilePdflatex(filename, false);
Figures.compilePdflatex(filename, true, true);


% matlab2tikz('export/SimplePolygonExample.tex')
% filename = '../../Dissertation/Thesis/Figures/SimplePolygonExample.tikz';
% matlab2tikz(filename, 'parseStrings', false,...
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '11cm',...
% ...    'height', '5cm', 
%     'extraAxisOptions',{'y post scale=1'});
% stn(filename);