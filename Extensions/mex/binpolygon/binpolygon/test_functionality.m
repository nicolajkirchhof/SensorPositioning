%%
load testcase8
%%
% idx = 1:numel(false_points_idx);
% idx = 22;

[in, on] = binpolygon(points_int(:,false_points_idx(idx)), poly_int);
%%%
[in1, on1] = binpolygon(points_int(:,false_points_idx(idx)), poly_int, 0, false);
%%
figure;
cla
hold on;
fill (poly_int(1,:), poly_int(2,:), 'b', 'facealpha', 0.3);
plot (poly_int(1,:), poly_int(2,:));
plot(points_int(1,false_points_idx(idx)), points_int(2,false_points_idx(idx)), '.g');
plot(points_int(1,false_points_idx(in)), points_int(2,false_points_idx(in)), '+r', 'MarkerSize', 10);
plot(points_int(1,false_points_idx(on)), points_int(2,false_points_idx(on)), '<r', 'MarkerSize', 10);
plot(points_int(1,false_points_idx(in1)), points_int(2,false_points_idx(in1)), '+m', 'MarkerSize', 10);
plot(points_int(1,false_points_idx(on1)), points_int(2,false_points_idx(on1)), '<m', 'MarkerSize', 10);
plot([points_int(1,false_points_idx(idx)); points_int(1,false_points_idx(idx))], [0 10000], 'r');

%% Generate test polygon
close all; clear all;
p{1} = [10, 25, 25, 10 ; 10, 10, 25, 10];
p{2} = int64([10, 25, 25, 10 ; 10, 10, 25, 10]);

pxy = linspace(0, 30, 10);
points = nchoosek(pxy, 2)';
pts{1} = [points [pxy; pxy] [points(2,:); points(1,:)]];
pts{2} = int64(pts{1});
tol = {0, 0};

files = dir('testcase*.mat');
for idf = 1:numel(files)
ts = load(files(idf).name);
p{end+1} = ts.poly_int;
% p{end+1} = ts.poly_dbl;
pts{end+1} = ts.points_int;
% pts{end+1} = ts.points_dbl;
tol{end+1} = 0;
% tol{end+1} = 0;
end

%%
for idp = 1:numel(p)
%     for idp = 10
    %%
%%% 
[in, on] = binpolygon(pts{idp}, p{idp}); 
[in1, on1] = binpolygon(pts{idp}, p{idp}, 0, false); 

%%

% if any(xor(in,in1)|xor(on, on1))
figure;
cla
hold on;
% indiff = xor(in,in1)|xor(on, on1);
fill (p{idp}(1,:), p{idp}(2,:), 'b', 'facealpha', 0.3);
plot (p{idp}(1,:), p{idp}(2,:));
plot(pts{idp}(1,:), pts{idp}(2,:), '.g');
% plot(pts{idp}(1,indiff), pts{idp}(2,indiff), 'hm', 'MarkerSize', 15);
% plot([pts{idp}(1,indiff); pts{idp}(1,indiff)], [ min(p{idp}(:)) max(p{idp}(:))], 'm');
plot(pts{idp}(1,on), pts{idp}(2,on), '<r', 'MarkerSize', 10);
plot(pts{idp}(1,in), pts{idp}(2,in), '+r', 'MarkerSize', 10);
plot(pts{idp}(1,in1), pts{idp}(2,in1), 'xb', 'MarkerSize', 10);
plot(pts{idp}(1,on1), pts{idp}(2,on1), '>b', 'MarkerSize', 10);
%%
% [in(indiff), on(indiff) in1(indiff), on1(indiff)]
% pts{idp}(:,indiff)
% % 
% %%
% indiff = 8874;
indiff = find(xor(in,in1)|xor(on, on1), 1, 'first');
if ~isempty(indiff)
[in, on] = binpolygon(pts{idp}(:,indiff), p{idp});
[in1, on1] = binpolygon(pts{idp}(:,indiff), p{idp}, 0, false);
%%
figure;
cla
hold on;
% % indiff = xor(in,in1)|xor(on, on1);
fill (p{idp}(1,:), p{idp}(2,:), 'b', 'facealpha', 0.3);
plot (p{idp}(1,:), p{idp}(2,:));
plot(pts{idp}(1,indiff), pts{idp}(2,indiff), '.r', 'MarkerSize', 15);
plot([pts{idp}(1,indiff); pts{idp}(1,indiff)], [ min(p{idp}(:)) max(p{idp}(:))], 'm');
% return;
% end
%%
% pause;
end
end