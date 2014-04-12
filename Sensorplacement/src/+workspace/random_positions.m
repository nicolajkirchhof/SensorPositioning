function pc = generate_random_workspace_positions(pc)

%% testinput
%%

% if isempty(pc.polymatlab)
%     pc.polymatlab = convert_poly_simple2matlab(pc.polymatlab.boundary);
% end

pc.polymatlab.dt = DelaunayTri(pc.polymatlab.boundary_verticies,pc.polymatlab.boundary_edges);  %# Create a constrained triangulation
% pc.polymatlab.dt = DelaunayTri(pc.polymatlab.verticies,pc.polymatlab.edges);  %# Create a constrained triangulation
pc.polymatlab.faces = pc.polymatlab.dt(pc.polymatlab.dt.inOutStatus,:);      %# Get the face indices of the inside triangles

%%
%calculate area sum though polygon and holes
pc.polymatlab.area_sum = abs(polygonArea(pc.polymatlab.boundary{1}));
for idp = 2:numel(pc.polymatlab.boundary)
    pc.polymatlab.area_sum = pc.polymatlab.area_sum-abs(polygonArea(pc.polymatlab.boundary{idp}));
end

% calculate commutive distribution
for idt = 1:size(pc.polymatlab.faces, 1)
    pc.polymatlab.areas(idt) = triangleArea(pc.polymatlab.boundary_verticies(pc.polymatlab.faces(idt,:), :));
    pc.polymatlab.area_prob(idt) = pc.polymatlab.areas(idt)/pc.polymatlab.area_sum;
end

pc.polymatlab.area_cdt = cumsum(pc.polymatlab.area_prob);

%%
%Calculate random Points
pc.problem.W = inf(2, pc.workspace.number_of_positions);
idpt = 1;
rng(pc.workspace.seed);
 while idpt <= pc.workspace.number_of_positions
     idx_poly = find(pc.polymatlab.area_cdt >= rand, 1, 'first');
     pt_cand = get_pointInPolygon(pc.polymatlab.boundary_verticies(pc.polymatlab.faces(idx_poly, :), :));
     if all(distancePoints(pt_cand', pc.problem.W')>pc.workspace.min_position_distance) % 
        pc.problem.W(:, idpt) = pt_cand;
        idpt = idpt+1;
     end
 end

pc.workspace.distance_matrix = distancePoints(pc.problem.W', pc.problem.W');
return 
%% verbose checking
dst = triu(distancePoints(pc.problem.W', pc.problem.W'));
min(dst(dst(:)>0))
% n = get_random_float(0,1)
% i = search_in_array(cdt, n)
% add_points_in_triangle(i)

%POINT IN TRIANGLE


function pt = get_pointInPolygon( poly )

u = poly(1,:) - poly(2,:);
v = poly(3, :) - poly(2, :);
unit = [rand, rand];

if sum(unit) > 1
    unit = 1-unit;
end

% unit.x * u.x + unit.y * v.x, unit.y * u.y + unit.y * v.y
pt = poly(2,:)' + [u' v'] * unit';

% vec pointInTriangle(vec a, vec b, vec c)
%     // make basis vectors from a->b and a->c
%     vec u = b - a
%     vec v = c - a
%
%     // pick a random point in the unit square
%     vec unit = vec(rand(0, 1), rand(0, 1))
%
%     // if the point is outside the triangle, remap it inside
%     // by mirroring it along the diagonal
%     if unit.x + unit.y > 1 then
%         unit = vec(1 - unit.y, 1 - unit.x)
%     end
%
%     // now transform it to fit the basis
%     return vec(unit.x * u.x + unit.y * v.x, unit.y * u.y + unit.y * v.y)
% end

%use the delauny constraint triangulation and the polygon areas to
%select a triangle in which a random point is created. Look at the
%links if someone already did it.
