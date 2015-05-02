function  draw( input, solution )
%DRAW Summary of this function goes here
%   Detailed explanation goes here
gcf
Environment.draw(input.environment, false);
hold on;
for ids = 1:numel(solution.sensors_selected)
    idss = solution.sensors_selected(ids);
    h = mb.fillPolygon(input.discretization.vfovs{idss}, 'k');
    set(h, 'facealpha', 0.1)
end
%%
x = input.discretization.wpn(1,:)
y = input.discretization.wpn(2,:)
z = ones(size(x))
scatter3(x,y,z, [], zeros(1,3), '.');

end

