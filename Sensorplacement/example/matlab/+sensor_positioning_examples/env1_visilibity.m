%example for sensor positioning calculation
%% %Clear the desk

clearvars *
format long;
is_display = true;
%init log
write_log(1) % print to standard output;
% write_log() % print to log_time.log output;
%generate the workspace
pc = create_processing_configuration;
%Read environment geometry from file
pc.environment.file =  'res/example1_int.environment';
pc.timing = {};
output_filename = [mfilename datestr(now, 30)];
write_log('loading environment... ');
tic; 
% pc = load_workspace(pc);
load res\polygons\environment1.mat
pc.environment.walls.ring = bpoly{1};
pc.environment.walls.poly = bpoly(1);
pc.environment.mountable.poly = cellfun(@(rng){fliplr(rng)}, bpoly(2:end), 'uniformoutput', false);
pc.environment.obstacles.poly = {};
pc.environment.occupied.poly = {};
pc.timing{end+1} = toc;
write_log('environment loaded in = %g sec',  pc.timing{end});
if is_display
figure, draw_environment(pc);
end

%%% generate the possible sensor and workspace positions
pc.workspace.sampling_technique = pc.common.sampling_techniques.grid;
pc.workspace.grid_position_distance = 200;
pc.workspace.number_of_positions = 1000;
pc.workspace.quality = 0.8;
pc.workspace.quality_technique = pc.common.sampling_techniques.uniform;
%%%
write_log('generating workspace... ');
tic;
pc = generate_workspace_positions(pc);
pc = generate_workspace_qualities(pc);
pc = generate_workspace_priorities(pc);
pc = generate_workspace_coverage(pc);
pc.timing{end+1} = toc;
write_log('workspace generated in = %g sec', pc.timing{end});

if is_display
    draw_workspace(pc);
% sp_size = {2,2};
% figure; subplot(sp_size{:}, 1); draw_workspace(pc); title('workspace');
% write_log('workspace generated time = %g', pc.timing{end});
end
%%% OPTIONAL : test min distance
%m = min(pc.workspace.distance_matrix(pc.workspace.distance_matrix>0));
% [r, c] = find(pc.workspace.distance_matrix == m);

%%%
pc.sensorspace.uniform_position_distance = 200;
pc.sensorspace.angles_sampling_occurence = pc.sensorspace.angles_sampling_occurences.pre;
pc.sensorspace.uniform_angle_distance = deg2rad(10);
pc.sensorspace.angles_sampling_technique = pc.common.sampling_techniques.uniform;
pc.sensorspace.min_angle_distance = deg2rad(10);
write_log('generating sensorspace... ');
tic;
pc = generate_sensorspace_positions(pc);
pc.timing{end+1} = toc;
write_log('sensorspace generated time = %g', pc.timing{end});
% figure(2); 
if is_display
    draw_sensorspace(pc);
% subplot(sp_size{:}, 3); draw_sensorspace(pc); title('sensorspace before visibility');
% write_log('sensorspace generated time = %g', pc.timing{end});
end
%%%
%%% Start building visibility matrices
tic;
write_log('calculating visibility... ');
pc = build_visibility_matrix(pc);
pc.timing{end+1} = toc;
% figure(3); 
write_log('visibility calculated time = %g', pc.timing{end});
%% save file for faster recovering
% save env1_visibility_calculated pc is_display
% clearvars 
load env1_visibility_calculated
%%
% if is_display
% figure, draw_visibility_matrix(pc, 0.1);
% 
% % alpha = 0.005;
% % subplot(sp_size{:}, 2); draw_visibility_matrix(pc, alpha); title(sprintf('visibility matrix alpha = %g', alpha));
% % subplot(sp_size{:}, 4); draw_sensorspace(pc); title('sensorspace after visibility');
% end
%% % check problem solveability
if ~all(sum(pc.problem.xt_ij, 1)>=2)
    error('solveability not given');
end

%% define vorbidden areas and cost vector
% pc = build_cost_vector(pc);
pc.r_j = ones(pc.workspace.number_of_positions, 1);
%% calculate lower and upper bounds
write_log('calculating bound constraint... ');
tic;
pc = build_sensorbounds_constraints(pc);
pc.timing{end+1} = toc;
write_log('constraint calculated in time = %g', pc.timing{end});

%% build constraints that no two sensors are allowed on same place
write_log('calculating bound constraint... ');
tic;
pc = build_sameplace_constraints(pc);
pc.timing{end+1} = toc;
write_log('constraint calculated in time = %g', pc.timing{end});

%% calculate priorities
write_log('calculating priority constraints... ');
tic;
pc = build_priority_constraints(pc);
pc.timing{end+1} = toc;
write_log('constraint calculated in time = %g', pc.timing{end});

%%
pc = build_cplex_model(pc);
pc.problem.cplex.solve();
pc.solution = pc.problem.cplex.Solution;

%% save 
save(output_filename, 'pc');
write_log('close');
%% work with solution



