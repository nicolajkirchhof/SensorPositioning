% function [ output_args ] = environments( input_args )
%ENVIRONMENTS Summary of this function goes here
%   Detailed explanation goes here
% end

%% Conference Room
    filename = 'res\floorplans\P1-Seminarraum.dxf';    
    environment = Environment.load(filename);
    environment = Environment.combine(environment);
    Environment.draw(environment, false);
    hold on;
    drawEdge(environment.combined_edges{1}(environment.placable_edges{1}, :), 'color', 'r', 'linewidth', 4);
    mb.drawPolygon(environment.combined, 'color', 'g', 'linestyle', ':', 'linewidth', 2);   
    save('tmp\conference_room\environment\environment.mat', 'environment');
%%
    filename = 'res\floorplans\SmallFlat.dxf';
    environment = Environment.load(filename);
    obst = environment.obstacles{7};
    obst{1}(2,:) = obst{1}(2,:) - 50;
    environment.obstacles{7} = obst;
    %%%
    environment = Environment.combine(environment);
    Environment.draw(environment, false);
    drawEdge(environment.combined_edges{1}(environment.placable_edges{1}, :), 'color', 'r', 'linewidth', 4);
    mb.drawPolygon(environment.combined, 'color', 'g', 'linestyle', ':', 'linewidth', 2);
    %%
    save('tmp\small_flat\environment\environment.mat', 'environment');

%%
    filename = 'res\floorplans\LargeFlat.dxf';
    environment = Environment.load(filename);
    rng = environment.boundary.ring;
    vrng = mb.boost2visilibity(rng);
    vsmp = simplifyPolyline(vrng, 90);
    environment.boundary.ring = mb.visilibity2boost(vsmp);
    Environment.draw(environment, false);
    drawPoint(vsmp);
    %%
    ring = environment.boundary.ring;
    environment = Environment.combine(environment);
    Environment.draw(environment, false);
    drawEdge(environment.combined_edges{1}(environment.placable_edges{1}, :), 'color', 'r', 'linewidth', 4);
    mb.drawPolygon(environment.combined, 'color', 'g', 'linestyle', ':', 'linewidth', 2);
    ylim([0 9500]);
    xlim([0 13000]);
    %%
    save('tmp\large_flat\environment\environment.mat', 'environment');

    %%
    filename = 'res\floorplans\P1-01-EtPart.dxf';
    environment = Environment.load(filename);
    ring = environment.boundary.ring;
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