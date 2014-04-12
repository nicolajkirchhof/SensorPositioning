function pc = evaluate_coverage(pc)

selected_sensors = pc.V(pc.solution.sensor_ids);
poly_covered = bpolyclip