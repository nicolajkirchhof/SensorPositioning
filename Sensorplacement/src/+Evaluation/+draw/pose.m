function pose(pose, length, linewidth)
%%
if nargin < 2 || isempty(length)
    length = 500;
end

if nargin < 3 || isempty(linewidth)
    linewidth = 3;
end

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
h = mb.drawPoint(pose(1:2, :), 'MarkerSize', 6, 'color', [0.5 0.5 0.5], 'LineWidth', linewidth);
legend(h(1), 'Sensorpose');
arrayfun(fun_legend_off, h(2:end));

rays = createRay(pose(1:2, :)', pose(3,:)');
rays(:,3:4) = bsxfun(@plus, rays(:,1:2), rays(:,3:4)*length);
h = drawEdge(rays, 'color', [0.2 0.2 0.2], 'LineWidth', linewidth);
arrayfun(fun_legend_off, h);

legend off;
% legend show;

if ~holdison
    hold off;
end

