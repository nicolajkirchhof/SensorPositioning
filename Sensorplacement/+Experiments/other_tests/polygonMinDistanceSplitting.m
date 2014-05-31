function polys = polygonMinDistanceSplitting(bring, cutedges)
%% testing minimizing of interpoint distance as linear opt problem
    ring_dbl = double(bring)';
    valid_edges = find(~cutedges);
    valid_combinations = comb2unique(valid_edges);
  %%
% ring_dbl = [ 0 0 ; 10 0; 10 5 ; 0 5; 0 0];
num_pts = size(ring_dbl, 1)-1;

%edges on which cut should take place
e1 = createLine(ring_dbl(valid_combinations(1,1),:), ring_dbl(valid_combinations(1,1)+1,:));
e2 = createLine(ring_dbl(valid_combinations(1,2),:), ring_dbl(valid_combinations(1,2)+1,:));
e = [e1;e2];
num_edges = 2;
%%
cp = Cplex('min_all_pointdistances');
%%
%       s, t, e1x, e1y, e2x, e2y, p1x, p1y, ...       ,dp11x, dp11y, ...
cp.Model.obj = [ 0, 0,   0,   0,   0,   0,  zeros(1, 2*num_pts),zeros(1,2*num_pts*num_edges)]';
cp.Model.Q = diag([ 0, 0, 0,  0,   0,   0,  zeros(1, 2*num_pts),ones(1, 2*num_pts*num_edges)]);
% cp.Model.ctype = repmat('C', 1, numel(obj));
cp.Model.lb = [0, 0, ones(1,4)           , ones(1,2*num_pts)  , -inf(1, 2*num_pts*num_edges)]';
cp.Model.ub = [1, 1, ones(1,4)           , ones(1,2*num_pts)  ,  inf(1, 2*num_pts*num_edges)]';
cp.Model.lhs = zeros(2*num_pts*num_edges, 1);
cp.Model.rhs = zeros(2*num_pts*num_edges, 1);

% dp11 = s*e1dx+e1x-p1x
% 0 <= s * e1dx + e1x  - p1x - dp11x <= 0
% 0 <= s * e1dy + e1y  - p1y - dp11y <= 0
% ...
% 0 <=

%         s, t, e1x, e1y, e2x, e2y, p1x, p1y,... dp11, dp21, dp31, dp41, dp12, dp22, dp32, dp42
% A = [ e1(3), 0, e1(1), 0,   0,   0,  -1,   0,      -1, ...
%       e1(4), 0, 0, e1(2),   0,   0,  0, -1, zeros(1,10);
%       0, e2(3), 0,     0, e1(1), 0,  0, 0,  1, zeros(1,9);
%       0, e2(4), 0,     0, 0, e1(2),  0, 0,  0, 1, zeros(1,8);]
%%   
% A = zeros(2*num_pts*num_edges, numel(obj));
s_col = [repmat(e1(3:4)', num_pts, 1); zeros(2*num_pts,1)];
t_col = [zeros(2*num_pts,1); repmat(e2(3:4)', num_pts, 1)];
e1x_col = [repmat([e1(1);0], num_pts, 1); zeros(2*num_pts, 1)];
e1y_col = [repmat([0;e1(2)], num_pts, 1); zeros(2*num_pts, 1)];
e2x_col = [zeros(2*num_pts, 1); repmat([e2(1);0], num_pts, 1)];
e2y_col = [zeros(2*num_pts, 1); repmat([0;e2(2)], num_pts, 1)];
pts = ring_dbl(1:num_pts,:)';
pts_col = repmat(-diag(pts(:)), 2, 1);
dp_col = diag(-ones(2*num_pts*num_edges,1));

cp.Model.A = [s_col, t_col, e1x_col, e1y_col, e2x_col, e2y_col, pts_col, dp_col];
cp.solve();
%%
p1 = e1(1:2)+(e1(3:4) * cp.Solution.x(1));
p2 = e2(1:2)+(e2(3:4) * cp.Solution.x(2));
drawPoint([p1;p2]);

%%
% A = zeros(2*num_pts*num_edges, numel(obj));
% cnt = 1;
% % for all edges
% for ide = 1:num_edges
%     % for all points
%     for idp = 1:num_pts
%         % for each coordinate x,y
%         for idc = 1:2
%             A(cnt, 
            
            
            