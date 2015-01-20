function draw(environment, discretization, quality, solution)


Discretization.draw(environment, discretization);

cellfun(@(x) mb.fillPolygon(x, 'k', 0.3), discretization.vfovs(solution.sensors_selected));

