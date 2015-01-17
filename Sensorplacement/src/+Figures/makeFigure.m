function makeFigure(figurename)



filename = '../../Dissertation/Thesis/Figures/SimplePolygonExample.tikz';
matlab2tikz(filename, 'parseStrings', false,...
    'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'width', '11cm',...
...    'height', '5cm', 
    'extraAxisOptions',{'y post scale=1'});
stn(filename);