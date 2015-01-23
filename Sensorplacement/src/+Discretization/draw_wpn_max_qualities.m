function draw_wpn_max_qualities(discretization, quality)    

    maxval = cellfun(@max, quality.wss.val);
    maxval(maxval==0) = eps;
    axis equal;
    xlim([0 4000]);
    ylim([800 8500]);
    scatter3(discretization.wpn(1,:)', discretization.wpn(2,:)', maxval, maxval*100, maxval, 'fill');
%     colorbar;
    title(sprintf('Num SP %d, Num WPN %d, MinQ %g', discretization.num_sensors, discretization.num_positions, min(maxval)));