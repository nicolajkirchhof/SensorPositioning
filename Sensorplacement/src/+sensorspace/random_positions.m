function pc = generate_random_sensorspace_positions(pc)

if isempty(pc.polymatlab)
    %%
    pc.polymatlab = convert_poly_simple2matlab(pc.poly);
end
    
pc.polymatlab.edge_lengths = edgeLength([pc.polymatlab.verticies(pc.polymatlab.edges(:,1), :), pc.polymatlab.verticies(pc.polymatlab.edges(:,2), :)]);
pc.polymatlab.edge_length_sum = sum(pc.polymatlab.edge_lengths); 
pc.polymatlab.edge_prob = pc.polymatlab.edge_lengths*(1/pc.polymatlab.edge_length_sum);
pc.polymatlab.edge_cdt = cumsum(pc.polymatlab.edge_prob);

%%
pc.problem.S = [];
%Calculate random Points
 for idpt = 1:pc.problem.num_sensors
     idx_edge = find(pc.polymatlab.edge_cdt >= rand, 1, 'first');
     lne = pc.polymatlab.verticies(pc.polymatlab.edges(idx_edge,:), :);
     pt = get_pointInEdge(lne);

     switch pc.sensorspace.angles_sampling_occurence
    case {2, 'within'}
%%
        pc = generate_sensorspace_angles(pc);
     end

     angles = mod(pc.sensorspace.angles + angle2Points(lne(1,:), lne(2,:)), 2*pi);
     
     pc.problem.S(1:3, end+1:end+pc.sensorspace.number_of_angles_per_position) = [repmat(pt, 1, pc.sensorspace.number_of_angles_per_position);angles];
 end

 
    function pt = get_pointInEdge(edge)
        pt = edge(1,:)' + diff(edge)'*rand;