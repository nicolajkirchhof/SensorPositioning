function draw_environment(pc)

holdison = false;
if ishold
    holdison = true;
end

%%
cla
fun_legend_off =@(h) set(get(get(h,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend

hold on;
axis equal;
% set(gca, 'color', [0.8 0.8 0.8]);
set(gcf, 'color', 'w');

h = mb.fillPolygon( pc.environment.walls.ring , 'w' );
legend(h, 'Workspace');

if ~isempty(pc.environment.occupied.poly)
    h = mb.fillPolygon( pc.environment.occupied.poly , [0.8 0.8 0.8]);
    legend(h(1), 'Occupied');
    arrayfun(fun_legend_off, h(2:end));
end

if ~isempty(pc.environment.obstacles.poly)
    h = mb.fillPolygon( pc.environment.obstacles.poly , [0.2 0.2 0.2]);
    legend(h(1), 'Obstacles');
    arrayfun(fun_legend_off, h(2:end));
end

if ~isempty(pc.environment.mountable.poly)
    h = mb.fillPolygon( pc.environment.mountable.poly , [0.5 0.5 0.5]);
    legend(h(1), 'Mountable');
    arrayfun(fun_legend_off, h(2:end));
end

h = mb.drawPolygon( pc.environment.walls.ring , 'color', 'k');
legend(h, 'Walls');
legend off;
legend show;
%
%
% mb.fillHoles( pc.environment.poly.boost , [0.8 0.8 0.8]  );
% mb.drawPolygon( pc.environment.poly.boost ,'color', 'k' , 'linewidth' , 2 );
% mb.drawPolygon( pc.environment.wall.ring, 'color', 'r' );
%%
if ~holdison
    hold off;
end




% function y = ismin(x, x_1)
% if x<x_1; y=x; else y=x_1; end
% function y = ismax(x, x_1)
% if x>x_1; y=x; else y=x_1; end
