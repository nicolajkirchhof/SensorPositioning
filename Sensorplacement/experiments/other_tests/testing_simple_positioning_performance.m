%%
%Clear the desk
clear all; close all; clc;
format long;

%positioning with simple 2/3 cover and no further constraints
%%

% sensorspace.uniform_angle_distance = deg2rad(10:5:45);
% sensorspace.uniform_position_distance_span = 0.2:0.2:2;
% workspace.grid_position_distance_span = 0.2:0.2:1;


sensorspace.uniform_angle_distance = deg2rad(45);
sensorspace.uniform_position_distance_span = 2;
workspace.grid_position_distance_span = 1;

all_runs = numel(sensorspace.uniform_angle_distance)* numel(sensorspace.uniform_position_distance_span) * numel(workspace.grid_position_distance_span);
cnt = 1; pct = 0;
fprintf(1, 'performing solvability test\n %% done');
%%
for id_ssp_uad = 1:numel(sensorspace.uniform_angle_distance)
    for id_ssp_upds = 1:numel(sensorspace.uniform_position_distance_span)
        for id_wsp_gpds = 1:numel(workspace.grid_position_distance_span)
            %% testing
%             id_ssp_uad = numel(sensorspace.uniform_angle_distance);
%             id_ssp_upds = numel(sensorspace.uniform_position_distance_span);
%             id_wsp_gpds = numel(workspace.grid_position_distance_span);
            %%
            if floor(cnt/all_runs)>pct
                pct = floor(cnt/all_runs);
                fprintf(1, '%d%%', pct);
            end
            cnt = cnt+1;
            %%
            wsp_gpds =  workspace.grid_position_distance_span(id_wsp_gpds);
            ssp_upds = sensorspace.uniform_position_distance_span(id_ssp_upds);
            ssp_uad = sensorspace.uniform_angle_distance(id_ssp_uad);
            %%testing
            
            
            % generate the workspace
            pc = create_workspace_configuration;
            %Read environment geometry from file
            pc.environment.file = './res/example2.environment';
            pc = load_workspace(pc);
            pc.name = sprintf('tspp_%gwsp_gpds_%gssp_upds_%gssp_uad', wsp_gpds, ssp_upds, rad2deg(ssp_uad));
            %     pc.poly = read_vertices_from_file('./res/example2.environment');
            %     pc.polycontour = convert_poly_simple2contour(pc.poly);
            
            %%%
            pc.workspace.sampling_technique = pc.workspace.sampling_techniques{3}; %grid
            pc.workspace.grid_position_distance = wsp_gpds;
            pc = generate_workspace_positions(pc);
            figure(1); plot_workspace(pc);
            % m = min(pc.workspace.distance_matrix(pc.workspace.distance_matrix>0));
            % [r, c] = find(pc.workspace.distance_matrix == m);
            %%%
            % generate the sensor candidate positions
            pc.sensorspace.uniform_angle_distance = ssp_uad;
            pc.sensorspace.uniform_position_distance = ssp_upds;
            pc = generate_sensorspace_positions(pc);
            figure(2); plot_sensorspace(pc);
            %
            % Start building visibility matrices
            %%%
            pc = build_visibility_matrix(pc, false);
            %%%
            % figure(3); draw_visibility_matrix(pc);
            %%% check solveability
            if any(sum(pc.problem.xt_ij', 2)<pc.k)
                pc.error = 'solveability not given';
                save_processing_configuration(pc);
                continue
            end
            
            %%%
            pc = build_cost_vector(pc);
            % define vorbidden areas
            pc.problem.r_j = ones(pc.workspace.number_of_positions, 1);
            
            pc = build_cplex_model(pc);
            pc.problem.cplex.solve();
            pc.problem.Solution = pc.problem.cplex.Solution;
            
            %
            save_processing_configuration(pc);
            %% clear pc;
            % wc2 = loadjson('tspp_1wsp_gpds_2ssp_upds_45ssp_uad.json');
        end
    end
end



%% plot solution
figure; plot_cplex_solution(pc);

%% test visibility of solution
num_sensors_per_point = pc.problem.xt_ij' * pc.problem.cplex.Solution.x;
figure; plot(num_sensors_per_point);
mean(num_sensors_per_point)
max(num_sensors_per_point)
median(num_sensors_per_point)
