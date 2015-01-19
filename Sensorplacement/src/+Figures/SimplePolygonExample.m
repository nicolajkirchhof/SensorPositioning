close all;
clear all;
%%
cla;
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

text(-60, -30, '$p_1$');
text(480, -30, '$e_6$');
text(-60, 400, '$e_1$');
text(-60, 830, '$p_2$');
text(520, 830, '$p_3$');
text(520, 540, '$p_4$');
text(1020, 540, '$p_5$');
text(1020, -30, '$p_6$');
text(230, 830, '$e_2$');
text(520, 650, '$e_3$');
text(750, 540, '$e_4$');
text(1020, 250, '$e_5$');

text(240, 170, '$p_1$');
text(40, 170, '$p_6$');
text(40, 330, '$p_5$');
text(420, 330, '$p_4$');
text(420, 70, '$p_3$');
text(240, 70, '$p_2$');
%%
Figures.makeFigure('SimplePolygonExample');

% matlab2tikz('export/SimplePolygonExample.tex')
% filename = '../../Dissertation/Thesis/Figures/SimplePolygonExample.tikz';
% matlab2tikz(filename, 'parseStrings', false,...
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '11cm',...
% ...    'height', '5cm', 
%     'extraAxisOptions',{'y post scale=1'});
% stn(filename);