%% Testing functionality for rectangular boundary
run c:\users\nico\workspace\tools.common\lib\matlab\matgeom.m
fun_drawPolygon = @(x) drawPolygon(x');
load test_rectboundary.mat
%%
[in, on] = binpolygon(int64(testpoints), testpoly, 1);
sum(in)
points_outside = testpoints(:, ~in);
idx_notin = find(~in);
%%
figure;
cla
hold on;
% fill (testpoly(1,:), testpoly(2,:), 'b', 'facealpha', 0.3);
cellfun(fun_drawPolygon, testpoly);
% plot (testpoly(1,:), testpoly(2,:));
plot(testpoints(1,:), testpoints(2,:), '.g');
plot(testpoints(1,in), testpoints(2,in), '+r', 'MarkerSize', 10);
plot(testpoints(1,on), testpoints(2,on), '<r', 'MarkerSize', 10);
%%
plot(testpoints(1,false_points_idx(in1)), testpoints(2,false_points_idx(in1)), '+m', 'MarkerSize', 10);
plot(testpoints(1,false_points_idx(on1)), testpoints(2,false_points_idx(on1)), '<m', 'MarkerSize', 10);
plot([testpoints(1,false_points_idx(idx)); testpoints(1,false_points_idx(idx))], [0 10000], 'r');

%%
[in, on] = binpolygon(int64(points_outside(:,1)), testpoly, 1);