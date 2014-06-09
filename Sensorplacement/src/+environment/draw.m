function draw(environment, islegend)

holdison = false;
if ishold
    holdison = true;
end

if nargin < 2
    islegend = true;
end

%%
cla
fun_legend_off =@(h) set(get(get(h,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend

hold on;
axis equal;
% set(gca, 'color', [0.8 0.8 0.8]);
set(gcf, 'color', 'w');

h = mb.fillPolygon( environment.boundary.ring , 'w' );
legend(h, 'Workspace');

if ~isempty(environment.occupied)
    h = mb.fillPolygon( environment.occupied , [0.8 0.8 0.8]);
    legend(h(1), 'Occupied');
    arrayfun(fun_legend_off, h(2:end));
end

if ~isempty(environment.obstacles)
    h = mb.fillPolygon( environment.obstacles , [0.2 0.2 0.2]);
    legend(h(1), 'Obstacles');
    arrayfun(fun_legend_off, h(2:end));
end

if ~isempty(environment.mountable)
    h = mb.fillPolygon( environment.mountable , [0.5 0.5 0.5]);
    legend(h(1), 'Mountable');
    arrayfun(fun_legend_off, h(2:end));
end

h = mb.drawPolygon( environment.boundary.ring , 'color', 'k');
legend(h, 'Walls');
legend off;
if islegend
    legend show;
end
%
%
% mb.fillHoles( pc.environment.boost , [0.8 0.8 0.8]  );
% mb.drawPolygon( pc.environment.boost ,'color', 'k' , 'linewidth' , 2 );
% mb.drawPolygon( pc.environment.wall.ring, 'color', 'r' );
%%
if ~holdison
    hold off;
end

return
%% TEST
% close all; 
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config = Configurations.Discretization.iterative;
environment = Environment.load(filename);

Environment.draw(environment);
