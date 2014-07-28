function draw( discretization, environment )
%DRAW draws the discretization into the environment
%%
Environment.draw(environment, false);
hold on;
Discretization.Sensorspace.draw(discretization.sp);
Discretization.Workspace.draw(discretization.wpn);
legend off;


end

