function fitness = fitness_opt3SensTrilatPrecalc(x, p_error, uc, t)
% calculate uncertainty polygon
uc_circ = {};
uc_poly = {};
diff_poly = {};
% sensors{end+1} = x;
% sensors = x;
% for idx_s = 1:numel(sensors)
%     [uc_circ{idx_s, 1} uc_circ{idx_s, 2}] = calc_uncertaintyCircles(uc, t, x);%sensors{idx_s});
    [uc_circ{1} uc_circ{2}] = calc_uncertaintyCircles(uc, t, x);%sensors{idx_s});
    for idx_circ = 1:2
        uc_poly{idx_circ} = create_PolygonStruct(circleToPolygon(uc_circ{idx_circ}, 500));
    end
    diff_poly = PolygonClip( uc_poly{2} , uc_poly{1}, 0 );
    %     plot_polygon(diff_poly{idx_s}, 'g');
    %     hold on;
    %     if idx_s > 1
    %         p_error = PolygonClip(diff_poly{idx_s}, diff_poly{idx_s-1}, 1);
    % %         plot_polygon(p_error, 'b')
    %         for idx = 1:numel(p_error)
    %             p_area(idx) = polyarea(p_error(idx).x, p_error(idx).y);
    %         end
    %     end
% end


p_error = PolygonClip(diff_poly, p_error, 1);
%         plot_polygon(p_error, 'b')
for idx = 1:numel(p_error)
    p_area(idx) = polyarea(p_error(idx).x, p_error(idx).y);
end

fitness = p_area(1);
% disp(fitness);
% pause(1);
