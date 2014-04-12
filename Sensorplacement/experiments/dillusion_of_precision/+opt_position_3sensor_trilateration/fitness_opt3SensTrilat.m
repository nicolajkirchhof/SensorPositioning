function fitness = fitness_opt3SensTrilat(t, sensors, uc)
% calculate uncertainty polygon
uc_circ = {};
uc_poly = {};
diff_poly = {};
p_error = {};
import side_evaluations.opt_position_3sensor_trilateration.*
for idx_s = 1:numel(sensors)
    [uc_circ{idx_s, 1} uc_circ{idx_s, 2}] = calc_uncertaintyCircles(uc, t, sensors{idx_s});
    for idx_circ = 1:2
        uc_poly{idx_circ} = circleToPolygon(uc_circ{idx_s, idx_circ}, 500)';
    end
    diff_poly{idx_s} = bpolyclip( uc_poly{2} , uc_poly{1}, 0, true );
    %     plot_polygon(diff_poly{idx_s}, 'g');
    %     hold on;
    if idx_s == 1
        p_error{idx_s} = diff_poly{idx_s};
    else %idx_s > 1
        p_error{idx_s} = bpolyclip(p_error{idx_s-1}, diff_poly{idx_s}, 1, true);
        %         plot_polygon(p_error, 'b')
        %         for idx = 1:numel(p_error)
        %             p_area(idx) = polyarea(p_error(idx).x, p_error(idx).y);
        %         end
    end
end

for idx = 1:numel(p_error{idx_s})
    p_area(idx) = mb.polygonArea(p_error{idx_s});
end
fitness = min(p_area);
% disp(fitness);
% pause(1);