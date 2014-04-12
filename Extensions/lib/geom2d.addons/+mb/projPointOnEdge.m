function [proj_pts, edge_position] = projectPointOnEdge(pts, edges)
% edge is represented by the endpoints p1 and p2
%%
edge_directions = edges(:,3:4)-edges(:,1:2);
length_squared = sum(edge_directions.^2, 2);

% Consider the line extending the segment, parameterized as v + t (w - v).
% We find projection of point p onto the line. 
% It falls where t = [(p-v) . (w-v)] / |w-v|^2

edge_position = sum(bsxfun(@minus,pts,edges(:,1:2)).*edge_directions,2) ./ length_squared;

% cap t outside of the edge back to the edge
edge_position(edge_position<0) = 0;
edge_position(edge_position>1) = 1;

proj_pts = edges(:,1:2)+bsxfun(@times, edge_position, edge_directions);