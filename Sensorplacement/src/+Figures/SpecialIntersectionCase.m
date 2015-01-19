close all;
clear all;
%%
clear variables;
cla;
axis equal
hold on;
axis off

filename = 'res/polygons/SpecialIntersectionCase.dxf';
[c_Line,c_Poly,c_Cir,c_Arc,c_Poi] = f_LectDxf(filename);

polys = c_Poly(:,1);
edges = c_Line(:,1);
circles = c_Cir(:,1);

for idl = [1,2,3,4,5,7,10,12,13,14]
%     pause; disp(idl)
    edges{idl} = edges{idl}([1,2,4,5])*100;
    drawEdge(edges{idl}, 'color', 'k', 'linewidth', 2, 'linestyle', '--');
end

for idl = [6,8,9,11]
%     pause; disp(idl)
    edges{idl} = edges{idl}([1,2,4,5])*100;
    drawEdge(edges{idl}, 'color', 'k', 'linewidth', 2, 'linestyle', ':');
end

for idp = 1:numel(polys)
    drawPolygon(polys{idp}*100, 'color', 'k', 'linewidth', 2);
 end
xlim([-100 16300]);
ylim([-100 9200]);
% axis on;

Figures.makeFigure('SpecialIntersectionCase');