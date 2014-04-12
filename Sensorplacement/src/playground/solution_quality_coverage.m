function pc = calculate_solution_goodness_coverage(pc)
%%
comb_poly = pc.problem.V{pc.problem.Solution.sensor_ids(1)};
for idx = 2:numel(pc.problem.Solution.sensor_ids)  
    comb_poly = polygon_clip(comb_poly, pc.problem.V{pc.problem.Solution.sensor_ids(idx)}, 3);
end
%%
pc.problem.Solution.areas_not_covered = polygon_clip(convert_poly_simple2contour(pc.polymatlab.boundary), comb_poly, 0);
% convert_poly_contour2geom2d(comb_poly)
% figure;plot_poly_contour(comb_poly);
% figure; plot_poly_contour(areas_not_covered);

pc.problem.Solution.area_not_covered = calculate_polyarea_contour(pc.problem.Solution.areas_not_covered);

