function draw_input( input )
%DRAW Summary of this function goes here
%   Detailed explanation goes here
id_empty = find(cellfun(@isempty, cellfun(@max, input.quality.wss.val, 'uniformoutput', false)));

%     figure;
cla;
Discretization.draw(input.discretization, input.environment);

axis equal;
if isempty(id_empty)
    maxval = cellfun(@max, input.quality.wss.val);
    scatter(input.discretization.wpn(1,:)', input.discretization.wpn(2,:)', [], maxval, 'fill');
    colorbar;
else
    maxval = 0;
    mb.drawPoint(input.discretization.wpn(:, id_empty), 'markersize', 20, 'markerfacecolor', 'r');
end
title(sprintf('Num SP %d, Num WPN %d, MinQ %g', input.discretization.num_sensors, input.discretization.num_positions, min(maxval)));


end

