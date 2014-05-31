function pc = uniform_positions(pc)
%%
pc.problem.S = [];
%sample walls and each mountable boundary independently
mountable = mb.flattenPolygon({pc.environment.walls.ring, pc.environment.mountable.poly{:}});
sensor_positions_wAngles = {};
%%
if pc.sensorspace.uniform_position_distance <= 0
    error('pc.sensorspace.uniform_position_distance must be > 0');
end

upd = pc.sensorspace.uniform_position_distance;
for idply = 1:numel(mountable)
    %%
    % using of linspace makes sure that every edge is spaced
    edges = mb.polygonGeomEdges(mountable{idply});
    edge_lengths =  mb.edgeLength(edges);
    % add one additional point in order to compensate rounding errors
%     num_edge_points = edge_lengths./pc.sensorspace.uniform_position_distance + int64(1);
    num_sampled_points = edge_lengths./10 + int64(1);
    
    sensor_positions_ring = {};
    %%
    for idedge = 1:size(edges, 1)
        spr = [int64(linspace(double(edges(idedge, 1)), double(edges(idedge, 3)),num_sampled_points(idedge)));...
            int64(linspace(double(edges(idedge, 2)), double(edges(idedge, 4)),num_sampled_points(idedge)))]';
        % filter sensor positions for obstacles and then remove all < dmax
        other_mountables = mountable([2:idply-1 idply+1:numel(mountable)]);
        if ~isempty(other_mountables) && ~isempty(pc.environment.obstacles.poly)
            [in] = binpolygon(spr', pc.environment.obstacles.poly) | binpolygon(spr', other_mountables);
        elseif ~isempty(pc.environment.obstacles.poly)
            [in] = binpolygon(spr', pc.environment.obstacles.poly);
        else
            in = false(size(spr,1),1);
        end
       % %% DEBUG
%         drawPoint(spr(in,:),'or')
%         drawPoint(spr(~in,:),'ok')
%%
        spr = spr(~in, :);
        %%%
        lin_dist_2_spr = sqrt(sum((spr(1:end-1,:)-spr(2:end,:)).^2, 2));
        
        flt = false(size(spr,1), 1);
        ids = 1;
%         flt(ids) = true; % 
        while ids <= size(spr,1)
            flt(ids) = true; %always true for ids = 1; chooses sensor if in sensor array
            lin_dist_csum = cumsum(lin_dist_2_spr(ids:end));
            ids = ids+sum(lin_dist_csum<upd)+1;            
        end
        %%
        if ~isempty(flt)
            flt(end) = true;
         %      %% 
                sensor_positions_ring{end+1} = spr(flt,:);
                num_edge_points(idedge) = sum(flt);
        else
            sensor_positions_ring{end+1} = [];
            num_edge_points(idedge) = 0;
        end
    end
    
    %%
    if pc.sensorspace.angles_sampling_occurence == pc.sensorspace.angles_sampling_occurences.within
        angles = cell(1,size(sensor_positions_ring, 1));
        for idpt = 1:size(sensor_positions_ring, 1);
            angles{idpt} = sensorspace_angles(pc);
        end
        error('mapping angles not implemented');
    else
        % map angles to points
        sensor_angles_ring_edges = mod(bsxfun(@plus, pc.sensorspace.angles, mb.angle2points(edges)), 2*pi);
        num_angles_per_position = size(sensor_angles_ring_edges, 2);
        replicate_positions_for_angles_function = @(x) repmat(x, num_angles_per_position, 1);
        %
        for idedge = 1:size(edges, 1)
            replicated_positions = arrayfun(replicate_positions_for_angles_function, sensor_positions_ring{idedge}, 'UniformOutput', false);
            replicated_positions = double(cell2mat(replicated_positions));
            sensor_positions_wAngles{end+1} = [replicated_positions, repmat(sensor_angles_ring_edges(idedge,:)', num_edge_points(idedge), 1)]';
        end
    end
    
end
pc.problem.S = cell2mat(sensor_positions_wAngles(~cellfun(@isempty, sensor_positions_wAngles)));



