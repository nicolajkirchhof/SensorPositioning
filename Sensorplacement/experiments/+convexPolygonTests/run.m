function run()

maps = {'rectangle4x4.environment'};
% define variations of input variables
workspace_position_distances = [1000, 500, 250, 100];
sensorspace_position_distances = [1000, 500, 250, 100];
sensorspace_angular_distances = deg2rad([45, 22.5, 11.25, 5.625]);

for map = maps
    for wdist = workspace_position_distances
        for sdist = sensorspace_position_distances
            for adist = sensorspace_angular_distances
                evaluate(map{1}, wdist, sdist, adist);           
            end 
        end
    end
end

function evaluate(map, wdist, sdist, adist)
outdir = 'evaluations/convexPolygonTests/';
indir = 'res/env/';

pc = processing_configuration;
pc.environment.file = [indir map];
pc.sensorspace.uniform_position_distance = sdist;
pc.sensorspace.uniform_angle_distance = adist;
pc.workspace.grid_position_distance = wdist;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc.workspace.quality.min = 0;


%%
% output_filename = [mfilename datestr(now, 30)];
if ~pc.common.verbose
    pc.common.logname = [pc.common.filename datestr(now, 30) '.log'];
    clear write_log
    write_log(pc.common.logname);
    
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

%%% Start building visibility matrices
write_log('calculating visibility... ');
pc = sensorspace_visibility_matrix(pc);
pc.common.timing{end+1} = toc;
% figure(3);
write_log('visibility calculated time = %g', pc.common.timing{end}-pc.common.timing{end-1});
if pc.common.is_display
    draw_visibility_matrix(pc)
end

%% build constraints that no two sensors are allowed on same place
write_log('calculating bound constraint... ');
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

%% calculate lower and upper bounds based on workspace properties
% here the need of new sensorspace positions might arise
write_log('calculating bound constraint... ');
pc = model_bounds(pc);
pc.common.timing{end+1} = toc;
write_log('constraint calculated in time = %g', pc.common.timing{end}-pc.common.timing{end-1});

%%
write_log('model simple problem... ');
pc = model_problem(pc);
pc.common.timing{end+1} = toc;
% figure(3);
write_log('simple problem modeled in time = %g', pc.common.timing{end});
if pc.common.is_display
    draw_visibility_matrix(pc)
end

outfile = [outdir map];
save(outfile, 'pc');



