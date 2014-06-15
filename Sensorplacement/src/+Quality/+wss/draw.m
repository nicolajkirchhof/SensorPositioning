function draw(quality, discretization)
%% DRAWSENSORPOSE(sp) draws one or more sensor poses given in [3 n] array

sp = discretization.sp;
wpn = discretization.wpn;
num_colors = 20;
[colors] = cool(20);
xsampl = linspace(0, 1, num_colors);
ids_wpn = 1:size(wpn, 2);

hold on;
% drawPoint(sp(1:2',:)', 'marker', '*', 'color', color);
% sp_phi_edge = createRay(sp(1:2, :)', sp(3, :)');
% sp_phi_edge(:,3:4) = bsxfun(@plus, sp_phi_edge(:,1:2), sp_phi_edge(:,3:4)*1000);
% drawEdge(sp_phi_edge, 'color', color);

%%
for id_wpn = ids_wpn
    cnt = 1;
    for id_sc = find(discretization.sc_wpn(:, id_wpn))'
        %%
        ids_sp = discretization.sc(id_sc, :);
        sp_phi_edge = createRay(sp(1:2, ids_sp)', sp(3, ids_sp)');
        sp_phi_edge(:,3:4) = bsxfun(@plus, sp_phi_edge(:,1:2), sp_phi_edge(:,3:4)*1000);
        q_col = max(interp1(xsampl, colors, quality.wss.val{id_wpn}(cnt)), [0 0 0]);
        if any(q_col>0)
        plyline = ([sp_phi_edge(1, 1:2);sp_phi_edge(1, 3:4); wpn(1:2, id_wpn)';sp_phi_edge(2, 3:4);sp_phi_edge(2, 1:2)]);
        drawPolyline(plyline, 'color', q_col);
        end
%         drawEdge(sp_phi_edge, 'color', q_col);
%         drawEdge(double([wpn(1:2, id_wpn), wpn(1:2, id_wpn)]'), sp_phi_edge(:, 3:4)', 'color', q_col);
        %%
        cnt = cnt+1;
    end
end
return;

%% TESTS
clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);

% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.WSS.kirchhof(discretization, config_quality);

%%
% quality.wss.val
% wpn = discretization.wpn;
% sp = discretization.sp;
Environment.draw(environment, false);
Quality.WSS.draw(quality, discretization);

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