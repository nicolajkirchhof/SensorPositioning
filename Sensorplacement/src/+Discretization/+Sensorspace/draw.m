function draw(sp, color)
%% DRAWSENSORPOSE(sp) draws one or more sensor poses given in [3 n] array

if nargin < 2
    color = 'k';
end

hold on;
drawPoint(sp(1:2',:)', 'marker', '*', 'color', color);
ray = createRay(sp(1:2, :)', sp(3, :)');
ray(:,3:4) = bsxfun(@plus, ray(:,1:2), ray(:,3:4)*1000);
drawEdge(ray, 'color', color);

return;

%% TEST
cla;
x = 1:1000:5000;
z = 0:pi/9:pi;
[g_x g_z] = meshgrid(x, z);
sensor_poses = [g_x(:), g_x(:), g_z(:)]';
sensor_poses_green = [sensor_poses(1:2,:) + 5000; sensor_poses(3,:)];

Discretization.Sensorspace.draw(sensor_poses);
Discretization.Sensorspace.draw(sensor_poses_green, 'g');

%% OLD VERSION
% 
% function draw(poses)
% %%
% 
% holdison = false;
% if ishold
%     holdison = true;
% end
% 
% hold on; 
% % drawPoint(pc.problem.S(1:2, :)');
% % rays = createRay(pc.problem.S(1:2, :)', pc.problem.S(3,:)');
% % rays(:,3:4) = bsxfun(@plus, rays(:,1:2), rays(:,3:4)*500);
% % hold on;
% 
% fun_legend_off =@(h) set(get(get(h,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','off'); % Exclude line from legend
% % h = drawEdge(rays);
% h = drawPoint(poses(1:2, :)', 'MarkerSize', 6);
% legend(h(1), 'Sensorspace');
% arrayfun(fun_legend_off, h(2:end));
% 
% legend off;
% legend show;
% 
% if ~holdison
%     hold off;
% end
% 
