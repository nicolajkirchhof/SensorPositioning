% function pc = run(pc)
% calculates the two coverage placement with and withoug distance, directional and combined
% constraints
% the following values will be adapted throughout the evaluation process

% pc.environment.file =  'res/floorplans/NicoLivingroom_NoObstacles.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangle.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithHole.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithThreeHoles.dxf';
% pc.environment.file =  'res/floorplans/SimpleRectangleWithObstacles.dxf';
% pc.environment.file = 'res/env/rectangle4x4.environment';
% pc.environment.file = 'res/env/simple_poly10_2.environment';
% pc.environment.file = 'res/env/simple_poly10_8.environment';
% pc.environment.file = 'res/env/simple_poly30_52.environment';
pc = processing_configuration('sides6_nr0');
pc.environment.file = 'res/env/convex_polygons/sides6_nr0.environment';
pc.sensorspace.uniform_position_distance = 600;
pc.sensorspace.uniform_angle_distance = deg2rad(45);
pc.workspace.grid_position_distance = 100;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc.sensors.quality.distance.max = 2000/pc.sensors.distance.max;
pc.model.distance_const.quality.min = 0.9;
pc.model.directional_sub.quality.min = 0.9;
pc.model.directional_sub.quality.max = 1.8;
pc.model.directional_const.quality.min = 0.9;
pc.model.directional_comb.quality.min = 0.9;
pc.model.directional_2comb.quality.min = 0.9;
%%
files = {'res/env/convex_polygons/sides3_nr0.environment';
    'res/env/convex_polygons/sides4_nr0.environment';
    'res/env/convex_polygons/sides5_nr0.environment';
    'res/env/convex_polygons/sides6_nr0.environment';
    'res/env/convex_polygons/sides7_nr0.environment';
    'res/env/convex_polygons/sides8_nr0.environment';
    'res/env/convex_polygons/sides9_nr0.environment';
    'res/env/convex_polygons/sides10_nr0.environment';};
sensorspace_uniform_position_distance = [600 350 150];
sensorspace_uniform_angle_distance = deg2rad([ 22.5 11.25 5.625 ]);
workspace_grid_position_distance = [ 600 350 150 ];

%% verbose
% if nargin < 1
    %%
 for file = files'
    for supd = sensorspace_uniform_position_distance
        for suad = sensorspace_uniform_angle_distance
            for wgpd = workspace_grid_position_distance
                
    [path, name, ext] = fileparts(file{1});
    pc = processing_configuration(name);
    pc.environment.file = file{1};               

pc.sensorspace.uniform_position_distance = 500;
pc.sensorspace.uniform_angle_distance = deg2rad(45/2);
pc.workspace.grid_position_distance = 500;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc.model.directional_sub.quality.min = 0.9;
pc.model.directional_const.quality.min = 0.9;
pc.model.directional_comb.quality.min = 0.9;
pc.model.directional_2comb.quality.min = 0.9;
% pc.common.debug = true;
pc.model.output.current = false;

pc = model.coverage(pc);
pc = model.save(pc);

pc = model.add.sameplace(pc);
pc = model.save(pc);

pc = model.add.directidonal_sub(pc);
pc = model.save(pc);

pc = model.clear(pc);
pc = model.directional_comb(pc);
pc = model.save(pc);

pc = model.clear(pc);
pc = model.coverage(pc);
pc = model.add.directional_const(pc);
pc = model.save(pc);

pc = model.clear(pc);
pc = model.directional_2comb(pc);
pc = model.save(pc);


            end 
        end
    end
end
%%
pc = model.coverage(pc);
pc = model.add.directional_const(pc);
pc = model.save(pc);
%%
pc = model.coverage(pc);
pc = model.add.directidonal_sub(pc);
pc = model.save(pc);
%%
pc = model.add.sameplace(pc);
pc = model.save(pc);  
%%%
pc = model.add.combinations(pc);
pc = model.save(pc);
%%%
pc = model.add.directidonal_sub(pc);
pc = model.save(pc);
%%
c = Cplex('tst');
c.readModel(pc.model.file.lastsave);
c.solve();
draw.solution(pc, c.Solution);
%%
pc = model.add.sameplace(pc);
pc = model.save(pc);  

%%
pc = model.add.combinations(pc);
pc = model.save(pc);
%%
pc = model.add.directidonal_sub(pc);
pc = model.save(pc);

%%
pc = model.coverage(pc);
model.write(pc);

%
pc = model.add.sameplace(pc);
model.write(pc);
%
pc = model.add.combinations(pc);
model.write(pc);
%%
pc = model.add.directional(pc);
model.write(pc);
%%
pc = model.distance(pc);
model.write(pc);
pc = model.add_sameplace(pc);
model.write(pc);
pc = model.add_directional(pc);
model.write(pc);

