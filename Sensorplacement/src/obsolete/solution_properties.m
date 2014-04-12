function pc = calculate_solution_properties(pc)
%%
    pc.problem.Solution.sensor_ids = find(pc.problem.Solution.x);
    pc.problem.Solution.sensor_num = sum(pc.problem.Solution.x);
    pc.problem.Solution.sensor_colors = hsv(pc.problem.Solution.sensor_num);
    pc.problem.Solution.xt_ij_selected = pc.problem.xt_ij(logical(pc.problem.Solution.x),:);
  
      
