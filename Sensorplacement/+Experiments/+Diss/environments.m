% function [ output_args ] = environments( input_args )
%ENVIRONMENTS Summary of this function goes here
%   Detailed explanation goes here
% end

%% Conference Room
    filename = 'res\floorplans\ConferenceRoom.dxf';    
    environment = Environment.load(filename);
%     environment.obstacles = {};
%     environment.mountable = {};
%     rng = environment.boundary.ring;
    mb.numberRings(environment.obstacles);
    %%
    obst = environment.obstacles{3}{1};
    obst(:, 3) = obst(:, 3)+1;
    environment.obstacles{3}{1} = obst;
    
    %%
    environment = Environment.combine(environment);
    Environment.draw(environment, false);
    hold on;
    drawEdge(environment.combined_edges{1}(environment.placable_edges{1}, :), 'color', 'r', 'linewidth', 4);
    mb.drawPolygon(environment.combined, 'color', 'g', 'linestyle', ':', 'linewidth', 2);
    %%
    save('tmp\conference_room\environment\environment.mat', 'environment');
%%
    filename = 'res\floorplans\SmallFlat.dxf';
    environment = Environment.load(filename);
%     obst = environment.obstacles{7};
%     obst{1}(2,:) = obst{1}(2,:) - 50;
%     environment.obstacles{7} = obst;
    %%%
    environment = Environment.combine(environment);
    Environment.draw(environment, false); hold on;
    drawEdge(environment.combined_edges{1}(environment.placable_edges{1}, :), 'color', 'r', 'linewidth', 4);
    mb.drawPolygon(environment.combined, 'color', 'g', 'linestyle', ':', 'linewidth', 2);
    %%%
    save('tmp\small_flat\environment\environment.mat', 'environment');

%%
    filename = 'res\floorplans\LargeFlat.dxf';
    environment = Environment.load(filename);
    rng = environment.boundary.ring;
    rng = mb.expandPolygon(rng, -13);
    environment.boundary.ring = rng;
%     vrng = mb.boost2visilibity(rng);
%     vsmp = simplifyPolyline(vrng, 80);
%     environment.boundary.ring = mb.visilibity2boost(vsmp{1});
    
    cla
    Environment.draw(environment, false);
    hold on;
%     drawPoint(vsmp{1});
    %%%
    ring = environment.boundary.ring;
    environment = Environment.combine(environment);
    size(environment.boundary.ring)
    %%%
    Environment.draw(environment, false);
    drawEdge(environment.combined_edges{1}(environment.placable_edges{1}, :), 'color', 'r', 'linewidth', 4);
    mb.drawPolygon(environment.combined, 'color', 'g', 'linestyle', ':', 'linewidth', 2);
    mb.drawPoint(environment.combined{1});
    ylim([0 9500]);
    xlim([0 13000]);
    %%%
    save('tmp\large_flat\environment\environment.mat', 'environment');

    %%
    filename = 'res\floorplans\P1-01-EtPart.dxf';
    environment = Environment.load(filename);
    ring = environment.boundary.ring;
%         vrng = mb.boost2visilibity(ring);
%         vsmp = simplifyPolyline(vrng, 80);
%         %%
    environment = Environment.combine(environment);
    Environment.draw(environment, false);
    hold on;
    drawEdge(environment.combined_edges{1}(environment.placable_edges{1}, :), 'color', 'r', 'linewidth', 4);
    mb.drawPolygon(environment.combined, 'color', 'g', 'linestyle', ':', 'linewidth', 2);
    %%%
    save('tmp\office_floor\environment\environment.mat', 'environment');
 
    %%
    hold on;
    for ido = 1:numel(environment.obstacles)
        mb.drawPolygon(environment.obstacles{ido});
        text(double(environment.obstacles{ido}{1}(1, 1)), double(environment.obstacles{ido}{1}(2, 1))-500, num2str(ido));
    end
    
    
    %%
                num_sp = 0;
            num_wpn = 0;
    config_discretization = Configurations.Discretization.iterative;
    config_discretization.workspace.wall_distance = 200;
    % config_discretization.workspace.cell.length = [0 1000];
    config_discretization.workspace.positions.additional = num_wpn;
    config_discretization.sensorspace.poses.additional = num_sp;
    config_discretization.common.verbose = 0;
    discretization = Discretization.generate(environment, config_discretization);
    
    %%%
    config_quality = Configurations.Quality.diss;
    [quality] = Quality.generate(discretization, config_quality);
    
    input.discretization = discretization;
    input.quality = quality;
    %         input.config.environment = config_environment;
    input.config.discretization = config_discretization;
    input.config.quality = config_quality;
    input.timestamp = datestr(now,30);
    input.name = name;
    
    input.environment = environment;
Experiments.Diss.draw_input(input)