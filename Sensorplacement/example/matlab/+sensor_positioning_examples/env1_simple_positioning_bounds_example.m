%example for sensor positioning calculation
%% %Clear the desk
tic;
clearvars *
format long;
%generate the workspace
pc = create_processing_configuration;
%Read environment geometry from file
pc.environment.file =  'res/example1_int.environment';
pc = load_workspace(pc);
write_log(1);
write_log('workspace loaded time = %g', toc);

%%% generate the possible sensor and workspace positions
pc.workspace.sampling_technique = pc.common.sampling_techniques.grid;
pc.workspace.grid_position_distance = 300;
pc.workspace.number_of_positions = 1000;
pc.workspace.quality = 0.8;
pc.workspace.quality_technique = pc.common.sampling_techniques.uniform;
%%%
pc = generate_workspace_positions(pc);
pc = generate_workspace_qualities(pc);
pc = generate_workspace_priorities(pc);
pc = generate_workspace_coverage(pc);

sp_size = {2,2};
figure; subplot(sp_size{:}, 1); draw_workspace(pc); title('workspace');
write_log('workspace generated time = %g', toc);

%%% OPTIONAL : test min distance
%m = min(pc.workspace.distance_matrix(pc.workspace.distance_matrix>0));
% [r, c] = find(pc.workspace.distance_matrix == m);

pc.sensorspace.uniform_position_distance = 200;
pc.sensorspace.angles_sampling_occurence = pc.sensorspace.angles_sampling_occurences.pre;
pc = generate_sensorspace_positions(pc);
% figure(2); 
subplot(sp_size{:}, 3); draw_sensorspace(pc); title('sensorspace before visibility');
write_log('sensorspace generated time = %g', toc);

%% % Start building visibility matrices

pc = build_visibility_matrix(pc);
% figure(3); 
write_log('visibility calculated time = %g', toc);
%%
alpha = 0.005;
subplot(sp_size{:}, 2); draw_visibility_matrix(pc, alpha); title(sprintf('visibility matrix alpha = %g', alpha));
subplot(sp_size{:}, 4); draw_sensorspace(pc); title('sensorspace after visibility');

%% % check problem solveability
if ~all(sum(pc.xt_ij, 1)>=2)
    error('solveability not given');
end

%% define vorbidden areas and cost vector
pc = build_cost_vector(pc);
pc.r_j = ones(pc.workspace.number_of_positions, 1);
return;
%% calculate lower and upper bounds
pc = calculate_sensorbounds_constraints(pc);
%%
pc.sensorspace.bounds.lower = 0;
pc.sensorspace.bounds.upper = inf;
pc = build_cplex_model(pc);
pc.problem.cplex.solve();
pc.solution.nobounds = pc.problem.cplex.Solution;


%% work with solution
pc = calculate_solution_properties(pc);

%% plot solution
figure, draw_cplex_solution(pc);
figure, draw_sensor_point_correspondences(pc);
return;
%% Evaluations
pc = calculate_solution_goodness(pc);

figure; plot_poly_contour(pc.solution.areas_not_covered); title(sprintf('Areas not covered sum = %f', pc.solution.area_not_covered));
%%
figure; boxplot(pc.solution.q_ang , 'plotstyle','compact', 'symbol', ''); 
title('Triangulation quality measure');
figure; boxplot(pc.solution.q_lat' , 'plotstyle','compact', 'symbol', '');
title('Trilateration quality measure');
%%
figure; 
boxplot(pc.solution.q_dist(:) , 'plotstyle','compact', 'symbol', ''); 
set(gca,'XTickLabel',{' '}); 
title('Distance from sensor to points');
%%

