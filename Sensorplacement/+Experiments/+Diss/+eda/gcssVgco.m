of_gco = all_eval.office_floor.gco{16, 1}
of_gcss = all_eval.office_floor.gcss{16, 1}

input = Experiments.Diss.office_floor(150, 0)

mb.fillPolygon(input.discretization.vfovs{of_gcss.sensors_selected(end-1)}, 'k', 'facealpha', 0.1)
%%
clf
hold on
Environment.draw(input.environment, false)
z = ones(size(input.discretization.wpn(2, :)));
plot3(input.discretization.wpn(1, :),input.discretization.wpn(2, :), z, 'k.')
for idp = numel(of_gcss.sensors_selected):-2:1
    h1 = mb.fillPolygon(input.discretization.vfovs{of_gcss.sensors_selected(idp)}, 'k', 'facealpha', 0.1)
    h2 = mb.fillPolygon(input.discretization.vfovs{of_gcss.sensors_selected(idp-1)}, 'k', 'facealpha', 0.1)
    disp(idp)
    pause
    delete([h1, h2]);
end

%%
clf
hold on
Environment.draw(input.environment, false)
z = ones(size(input.discretization.wpn(2, :)));
plot3(input.discretization.wpn(1, :),input.discretization.wpn(2, :), z, 'k.')
for idp = numel(of_gco.sc_selected):-1:1
    sc = input.discretization.sc(of_gco.sc_selected(idp), :)
    mb.fillPolygon(input.discretization.vfovs{sc(1)}, 'k', 'facealpha', 0.1)
    mb.fillPolygon(input.discretization.vfovs{sc(2)}, 'k', 'facealpha', 0.1)
    disp(idp)
    pause
end