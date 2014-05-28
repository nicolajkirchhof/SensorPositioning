function draw_workspace(pc)

holdison = false;
if ishold
    holdison = true;
end

hold on; 
h = drawPoint(pc.problem.W', '.g');
legend(h(1), 'Workspace Point');
legend off;
legend show;

if ~holdison
    hold off;
end