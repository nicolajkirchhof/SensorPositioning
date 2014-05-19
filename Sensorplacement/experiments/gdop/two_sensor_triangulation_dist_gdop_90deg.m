function two_sensor_triangulation_dist_gdop_90deg%(fov, max_dist, s1x, s2x,distance_factor)
% only function in order to keep workspace clean;
close all;
clear all;
%%% Evaluation of distances for different angles
uc_fov = 6;
uc_fov_2 = uc_fov/2;
s1 = [0, 0];
s2 = [0, 0];
dmax = 10000;
s1_poly = flipud(int64([s1; circleArcToPolyline([s1, 10000, 90-uc_fov_2, uc_fov], 64)]));
s2_poly = flipud(int64([s2; circleArcToPolyline([s2, 10000, 180-uc_fov_2, uc_fov], 64)]));

distances = 50:50:9500;
pcuts = cell(numel(distances), numel(distances));
ds1 = zeros(size(pcuts));
ds2 = zeros(size(pcuts));
cnt = 1;
dist1 = distances(2);
dist2 = distances(2);
%
for dist1 = distances
    t1 = [0, -dist1];
    for dist2 = distances
        %%
        t2 = [dist2, 0];
        ds2(cnt) = dist2;
        ds1(cnt) = dist1;
        s1_pmoved = mb.polygonTranslate(s1_poly', t1');
        s2_pmoved = mb.polygonTranslate(s2_poly', t2);
%         figure, hold on, mb.drawPolygon(s1_pmoved'), mb.drawPolygon(s2_pmoved')
        %%
        pcuts{cnt} = bpolyclip(s1_pmoved, s2_pmoved, 1, true);
        cnt = cnt + 1;
    end
end
%
psize = arrayfun(@mb.polygonArea, pcuts);
plength = arrayfun(@mb.polygonLength, pcuts);

qd1d2 = ds1.*ds2;
qd1d2pl = ds1+ds2;

qcust = ((ds1/dmax)+1).*((ds2/dmax)+1);

pid = arrayfun(@mb.polygonInterpointDistances, pcuts, 'uniformoutput', false);
pidmax = arrayfun(@(x) max(x{1}), pid);
pidmean = arrayfun(@(x) mean(x{1}), pid);
%%
figure,
sz = {1,3};
plt = 1;
subplot(sz{:}, plt)
% mesh(ds1, ds2, psize);
imagesc(psize);
title('polygon size for different d1 ds at 90°');
axis off;

plt = plt+1;
subplot(sz{:}, plt)
% mesh(ds1, ds2, qd1d2);
imagesc(qd1d2);
title('quality (d1*d2) for different distances at 90°');
axis off;
% plt = plt+1;
% subplot(sz{:}, plt)
% % mesh(ds1, ds2, pidmax);
% imagesc(pidmax);
% title('max ip dist for different distances at 90°');

% plt = plt+1;
% subplot(sz{:}, plt)
% % mesh(ds1, ds2, pidmax);
% imagesc(pidmean);
% title('mean ip dist for different distances at 90°');

% plt = plt+1;
% subplot(sz{:}, plt)
% % mesh(ds1, ds2, pidmax);
% imagesc(qd1d2pl);
% title('ds1 + ds2 plus for different distances at 90°');
% 
% 
% plt = plt+1;
% subplot(sz{:}, plt)
% % mesh(ds1, ds2, plength);
% imagesc(plength);
% title('polygon length for different distances at 90°');

plt = plt+1;
subplot(sz{:}, plt)
% mesh(ds1, ds2, qcust);
imagesc(qcust);
title('custom range func for different distances at 90°');
axis off

%%
%%% Evaluation of dist/angle
% figure, drawPolygon(s1_poly)
distances = 100:1000:9000;
dist = distances(1);
num_angles = 90;
pcut = cell(num_angles, numel(distances));
% angs = zeros(size(pcut));
cnt = 1;
for dist = distances
    circlepoints = round(circleArcToPolyline([0, 0, dist, -90, 90], num_angles))';
    %%
    for pt = circlepoints
%         fprintf('%f, %f, \n', pt);
    %%
        ang = 180 + atan2d(pt(2),pt(1));
        angs(cnt) = ang;
        s2_poly = flipud(int64([pt'; circleArcToPolyline([pt', 10000, ang-uc_fov_2, uc_fov], 64)]));
        pcut{cnt} = bpolyclip(s1_poly', s2_poly', 1, true);
%        figure, hold on, drawPolygon(s1_poly), drawPolygon(s2_poly), axis equal
%     figure, mb.drawPolygon(pcut{1}),
    %%
    cnt = cnt+1;
    end
end
%%

psize = arrayfun(@mb.polygonArea, pcut, 'uniformoutput', false);
psize = cell2mat(psize);
%%
kvisualize = false;
% visualize = true;
% max_dist = 10;
fov_2 = fov/2;
% fov = 2*fov_2;

%  target_dist = s1(1,1)-target(1,1);
num_points = 1800;

num_distances = numel(1:dist_step:max_dist);

sol.s1_s2_and_area = cell(1,num_distances);
sol.s1_s2_and_length = cell(1,num_distances);
% phi = cell(1,num_distances);
% phi2 = cell(1,num_distances);
sol.s1_s2_and_dmax = cell(1,num_distances);
sol.s1_s2_quality_dd_dop= cell(1,num_distances);
sol.s1_s2_quality_kelly= cell(1,num_distances);

cnt = 1;
% for target_dist = 1:dist_step:max_dist;
for target_dist = [0.5, 1, 2, 3, 4, 5, 6]
s1 = [target_dist;0;180];
s2 = [target_dist;0;180];
sensor_path = circleArcToPolyline([0, 0, target_dist, 0, 180], num_points);
%%%
s1_ang = cell(1,num_points);
% s2_ang = cell(1,num_points);
s1_fov_pline = cell(1,num_points);
% s2_fov_pline = cell(1,num_points);
s1_poly = cell(1,num_points);
% s2_poly = cell(1,num_points);
s1_s2_and = cell(1,num_points);
s1_s2_and_area = nan(1,num_points);
s1_s2_and_length = nan(1,num_points);
phi = nan(1,num_points);
% phi2 = nan(1,num_points);
s1_s2_and_dmax = nan(1,num_points);
s1_s2_quality_dd_dop= nan(1,num_points);
s1_s2_quality_dampster= nan(1,num_points);
s1_s2_quality_kelly= nan(1,num_points);
s2_fov_pline = circleArcToPolyline([s2(1:2,1)', max_sensor_dist, 180-fov_2, fov], 500);
%     s2_poly.x = [s2_fov_pline(:,1); s2(1,1)];
%     s2_poly.y = [s2_fov_pline(:,2); s2(2,1)];
%     s2_poly.hole = 0;
s2_poly = [s2_fov_pline; s2(1:2,1)'];
% cla; draw_polycontour(s2_poly);
dmax = (max_sensor_dist^2)/distance_factor;
%%%   
if visualize; cla; hold on; end;
for idp = 1:size(sensor_path, 1)
    s1(1:2,1) = sensor_path(idp,:)';
    s1_ang{idp} = rad2deg(angle2Points(s1(1:2,1)', target'));
%     s1_ang{idp} = rad2deg(angle3Points(s1(1:2,1)', target', s2(1:2,1)'));
    s1_fov_pline{idp} = circleArcToPolyline([s1(1:2,1)', max_sensor_dist, s1_ang{idp}-fov_2, fov], 500);
%     s2_fov_pline{idp} = circleArcToPolyline([s2(1:2,1)', max_dist, s2_ang{idp}-fov_2, fov], 50);
%     s1_poly{idp}.x = [s1_fov_pline{idp}(:,1); s1(1,1)];
%     s1_poly{idp}.y = [s1_fov_pline{idp}(:,2); s1(2,1)];
%     s1_poly{idp}.hole = 0;
      s1_poly{idp} = [s1_fov_pline{idp}; s1(1:2,1)'];
%     s2_poly{idp}.x = [s2_fov_pline{idp}(:,1); s2(1,1)];
%     s2_poly{idp}.y = [s2_fov_pline{idp}(:,2); s2(2,1)];
%     s2_poly{idp}.hole = 0;

    out_multipoly = bpolyclip(s1_poly{idp}', s2_poly', 1, true)';
    if ~isempty(out_multipoly)
    s1_s2_and{idp} = out_multipoly{1}{1}';
    else 
        continue;
    end
%     s1_s2_and{idp} = clipper(s1_poly{idp}, s2_poly, 1, 1e6);
    phi(idp) = rad2deg(angle3Points(s2(1:2,1)', target' ,s1(1:2,1)'));
%     phi2(idp) = rad2deg(angle2Points(sensor_path(idp, :),s1(1:2,1)'));
    if visualize
    drawPolygon(s1_poly{idp}, 'g'); 
%     fillPolygon(s1_s2_and{idp}, 'k'); title(sprintf('phi = %g', phi(idp)));
%     pause
    end
    
    q_sin = single(sin(mb.angle3PointsFast(s1(1:2, 1), target, s2(1:2, 1))))';    
    ds1 = mb.distancePoints(target, s1(1:2, 1))';
    ds2 = mb.distancePoints(target, s2(1:2, 1))';
        
    s1_s2_and_area(idp) = polygonArea(s1_s2_and{idp});
    s1_s2_and_length(idp) = polygonLength(s1_s2_and{idp});
    s1_s2_quality_dd_dop(idp) = q_sin./(1+(ds1.*ds2/dmax));
    try
    s1_s2_quality_dampster(idp) = gdop(target(1), target(2), s1(1,1), s1(2,1), s2(1,1), s2(2,1));
    catch e
        disp(e);
        s1_s2_quality_dampster(idp) = 0;
    end
    s1_s2_quality_kelly(idp) = (ds1.*ds2)/q_sin;
    D = distancePoints(s1_s2_and{idp}, s1_s2_and{idp});
    s1_s2_and_dmax(idp) = max(D(:));
end

sol.s1_s2_and_area{cnt} = s1_s2_and_area;
sol.s1_s2_and_length{cnt} = s1_s2_and_length;
% phi = nan(1,num_distances);
% phi2 = nan(1,num_distances);
sol.s1_s2_and_dmax{cnt} = s1_s2_and_dmax;
sol.s1_s2_quality_dd_dop{cnt}= s1_s2_quality_dd_dop;
sol.s1_s2_quality_dampster{cnt} = s1_s2_quality_dampster;
sol.s1_s2_quality_kelly{cnt}= s1_s2_quality_kelly;
cnt = cnt+1;
if visualize; drawPolygon(s2_poly, 'r'); pause; end;
end

%%%
figure; 
num_plots = numel(sol.s1_s2_quality_dampster);
sz = {num_plots, 6};
all_axes = nan(1, num_plots*6);
cnt = 1;
x = linspace(0, 180, num_points);
for ids = 1:num_plots
% subplot(2,2,1); plot(phi); title('phi')
% subplot(3,2,1); plot(sin(deg2rad(phi))); title('sin(phi)');
% subplot(3,2,2); plot(1-sin(deg2rad(phi))); title('1-sin(phi)')
all_axes(cnt) = subplot(sz{:},cnt); plot(x, sol.s1_s2_quality_dd_dop{ids}); title('dd_dop_quality')
cnt = cnt +1;
sol.s1_s2_quality_kelly{ids}(sol.s1_s2_quality_kelly{ids}>100) = 100;
all_axes(cnt) = subplot(sz{:},cnt); plot(x, sol.s1_s2_quality_kelly{ids}); title('kelly gdop')
xlim([0 180]);
cnt = cnt +1;
sol.s1_s2_quality_dampster{ids}(sol.s1_s2_quality_dampster{ids}>100) = 100;
all_axes(cnt) = subplot(sz{:},cnt); plot(x, sol.s1_s2_quality_dampster{ids}); title('dampster gdop')
xlim([0 180]);
cnt = cnt +1;
% kelly = 1./sin(deg2rad(phi));
% kelly(kelly>1e2) = 1e2;
% subplot(3,2,3); plot(kelly); title('1/sin(phi)');
all_axes(cnt) = subplot(sz{:},cnt); plot(x, sol.s1_s2_and_area{ids}); title('area');
xlim([0 180]);
cnt = cnt +1;
all_axes(cnt) = subplot(sz{:},cnt); plot(x, sol.s1_s2_and_length{ids}); title('length');
xlim([0 180]);
cnt = cnt +1;
all_axes(cnt) = subplot(sz{:},cnt); plot(x, sol.s1_s2_and_dmax{ids}); title('max point dist');
xlim([0 180]);
cnt = cnt +1;
end
%
arrayfun(@(h) xlim(h, [0 180]), all_axes);
arrayfun(@(h) set(h, 'xtick', [0 45 90 135 180]), all_axes);
arrayfun(@(h) ylim(h, [0 1]), all_axes(1:6:end));

%%
return;
%%
col = repmat((0:10)', 1, 3)*0.1;
cla;
hold on;
ylim([0 6]);

title('max point dist');
xlabel('Inner bearing Angle');
ylabel('Max interpoint distance');


text('Interpreter', 'none', 'position', [30 0.4], 'string', 'd1')
text('Interpreter', 'none', 'position', [40 0.8], 'string', 'd2')
text('Interpreter', 'none', 'position', [50 1.2], 'string', 'd3')

x = linspace(0, 180, 1800);
e1 = 1;
e2 = 3; 
e3 = 5;
plot(x, sol.s1_s2_and_dmax{e1}, 'color', col(1,:), 'linewidth', 1, 'linestyle', '--');
plot(x, sol.s1_s2_and_dmax{e2}, 'color', col(3,:), 'linewidth', 1, 'linestyle', '--');
plot(x, sol.s1_s2_and_dmax{e3}, 'color', col(5,:), 'linewidth', 1, 'linestyle', '--');
% plot(x, sol.s1_s2_and_dmax{6}, 'color', col(7,:), 'linewidth', 1, 'linestyle', '--');
q_flt1 = sol.s1_s2_quality_dd_dop{e1}>=0.3;
q_flt2 = sol.s1_s2_quality_dd_dop{e2}>=0.3;
q_flt3 = sol.s1_s2_quality_dd_dop{e3}>=0.3;
plot(x(q_flt1), sol.s1_s2_and_dmax{e1}(q_flt1), 'color', col(1,:), 'linewidth', 2, 'linestyle', '-');
plot(x(q_flt2), sol.s1_s2_and_dmax{e2}(q_flt2), 'color', col(3,:), 'linewidth', 2, 'linestyle', '-');
plot(x(q_flt3), sol.s1_s2_and_dmax{e3}(q_flt3), 'color', col(5,:), 'linewidth', 2, 'linestyle', '-');

matlab2tikz('fig/thilouncertainty.tex');

