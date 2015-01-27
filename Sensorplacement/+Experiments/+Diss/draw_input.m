function draw_input( input )
%DRAW Summary of this function goes here
%   Detailed explanation goes here
    maxval = cellfun(@max, input.quality.wss.val);
%     figure;
    cla;
    Discretization.draw(input.discretization, input.environment);

    axis equal;
    scatter(input.discretization.wpn(1,:)', input.discretization.wpn(2,:)', [], maxval, 'fill');
    colorbar;
    title(sprintf('Num SP %d, Num WPN %d, MinQ %g', input.discretization.num_sensors, input.discretization.num_positions, min(maxval)));


end

