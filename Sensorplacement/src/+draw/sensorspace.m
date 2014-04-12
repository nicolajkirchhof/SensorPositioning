function draw_sensorspace(pc)
%%

holdison = false;
if ishold
    holdison = true;
end

hold on; 
% drawPoint(pc.problem.S(1:2, :)');
% rays = createRay(pc.problem.S(1:2, :)', pc.problem.S(3,:)');
% rays(:,3:4) = bsxfun(@plus, rays(:,1:2), rays(:,3:4)*500);
% hold on;

fun_legend_off =@(h) set(get(get(h,'Annotation'),'LegendInformation'),...
    'IconDisplayStyle','off'); % Exclude line from legend
% h = drawEdge(rays);
h = drawPoint(pc.problem.S(1:2, :)', 'MarkerSize', 6);
legend(h(1), 'Sensorspace');
arrayfun(fun_legend_off, h(2:end));

legend off;
legend show;

if ~holdison
    hold off;
end

