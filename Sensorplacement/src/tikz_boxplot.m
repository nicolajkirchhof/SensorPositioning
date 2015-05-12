function[handle]=tikz_boxplot(Data,XTickLabel,XLabel)
% -------------------------------------------------------------------------
% Workaround for boxplots in combination with matlab2tikz(). As reported,
% matlab2tikz fails to export boxplots correctly, mostly due to the quite
% 'special' implementation of boxplot() itself. The error "dimension too 
% large" will occur when compiling an automatically exported boxplot in 
% Latex due to a wrong positioning of the XTickLabels. This short code 
% provides a solutions through erasing the old labels and setting new ones 
% with correct positions. 
% Execute this before running matlab2tikz()...
% -------------------------------------------------------------------------
% IN:
%       Data       - Data to be displayed, same requirements as for 
%                    boxplot()
%       XTickLabel – Cell-array of strings to be set on X-axis, length
%                    should be equal to size(Data,2).
%       XLabel     - String to be placed as label on X-axis
% OUT:
%       handle     - figure handle
% -------------------------------------------------------------------------
boxplot(Data);                       % execute original boxplot
txt    = findall(gcf,'type','text'); % get x-tick-label handles
delete(txt)                          % erase handles
% set x tick labels :
for i=1:size(Data,2)                 % number of box plot bars in figure
    text('Interpreter','latex',...
         'String',XTickLabel{i},...
         'Units','normalized',...
         'VerticalAlignment','top',...
         'HorizontalAlignment','center',...
         'Position',[1/(size(Data,2)*2)*(1+2*(i-1)),-0.01],...x/y position
         'EdgeColor','none')
end
% set x label:
text('Interpreter','latex',...
     'String',XLabel,...
     'Units','normalized',...
     'VerticalAlignment','top',...
     'HorizontalAlignment','center',...
     'Position',[0.5,-0.07],...
     'EdgeColor','none')
handle = gcf; %                   Get figure handle for further alterations 
end
 


