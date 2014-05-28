function pc = calculate_all_optimization_properties(pc)
%example for sensor positioning calculation
%% verbose
if nargin < 1
    %%
pc = processing_configuration;
% pc.environment.file =  'res/floorplans/NicoLivingroom_NoObstacles.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangle.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithHole.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithThreeHoles.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithObstacles.dxf';
% pc.environment.file = 'res/env/rectangle4x4.environment';
% pc.environment.file = 'res/env/simple_poly10_2.environment';
% pc.environment.file = 'res/env/simple_poly10_8.environment';
% pc.environment.file = 'res/env/simple_poly30_52.environment';
pc.environment.file = 'res/env/convex_polygons/sides6_nr0.environment';
pc.sensorspace.uniform_position_distance = 500;
pc.sensorspace.uniform_angle_distance = deg2rad(11.25);
pc.workspace.grid_position_distance = 500;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc.workspace.quality.min = 0;

end
%%
% output_filename = [mfilename datestr(now, 30)];
if ~pc.common.verbose
    pc.common.logname = [pc.common.filename datestr(now, 30) '.log'];
    clear write_log
    write_log(pc.common.logname);
else
    write_log(1);
end
%
write_log('loading and decomposing environment... ');
tic;
pc = environment_load(pc);
% pc = environment_decompose(pc);
pc.common.timing{end+1} = toc;
write_log('environment loaded in = %g sec',  pc.common.timing{end});
if pc.common.is_display
    figure, draw_environment(pc);
end

%% generate the workspace positions %%%
write_log('generating workspace... ');
pc = workspace_positions(pc);
% pc = generate_workspace_qualities(pc); % trivial, therefore not included
% pc = generate_workspace_priorities(pc); % 
pc = workspace_coverage(pc);
pc.common.timing{end+1} = toc;
write_log('workspace generated in = %g sec', pc.common.timing{end}-pc.common.timing{end-1});

if pc.common.is_display
    draw_environment(pc);
    draw_workspace(pc);
end

%%% generate the sensorspace positions %%%
write_log('generating sensorspace... ');
pc = sensorspace_positions(pc);
pc.common.timing{end+1} = toc;
write_log('sensorspace generated time = %g', pc.common.timing{end}-pc.common.timing{end-1});
if pc.common.is_display
    draw_sensorspace(pc);
end

%% calculate lower and upper bounds based on workspace properties
% here the need of new sensorspace positions might arise
% write_log('calculating bound constraint... ');
% pc = model_cutoffs(pc);
% pc.common.timing{end+1} = toc;
% write_log('constraint calculated in time = %g', pc.common.timing{end}-pc.common.timing{end-1});

%%% Start building visibility matrices
write_log('calculating visibility... ');
pc = sensorspace_visibility_matrix(pc);
pc.common.timing{end+1} = toc;
% figure(3);
write_log('visibility calculated time = %g', pc.common.timing{end}-pc.common.timing{end-1});
if pc.common.is_display
    draw_visibility_matrix(pc)
end

%%%
%% % check problem solveability
% if ~all(sum(pc.problem.xt_ij, 1)>=2)
%     error('solveability not given');
% end

%% define vorbidden areas and cost vector
% pc = build_cost_vector(pc);
% pc.r_j = ones(pc.workspace.number_of_positions, 1);
% pc.problem.ct = ones(pc.problem.num_sensors, 1);


%% build constraints that no two sensors are allowed on same place
write_log('calculating sameplace constraint... ');
tic;
pc = sensorspace_sameplace_constraints(pc);
pc.common.timing{end+1} = toc;
write_log('constraint calculated in time = %g', pc.common.timing{end});

%% calculate priorities
write_log('calculating quality constraints... ');
tic;
pc = sensorspace_quality_constraints(pc);
pc.common.timing{end+1} = toc;
write_log('constraint calculated in time = %g', pc.common.timing{end});

write_log('model simple problem... ');
pc = model_problem(pc);
pc.common.timing{end+1} = toc;
% figure(3);
write_log('simple problem modeled in time = %g', pc.common.timing{end});
if pc.common.is_display
    draw_visibility_matrix(pc)
end


