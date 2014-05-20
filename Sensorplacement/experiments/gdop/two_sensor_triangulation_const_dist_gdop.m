function two_sensor_triangulation_const_dist_gdop%(fov, max_dist, s1x, s2x,distance_factor)
% only function in order to keep workspace clean;
close all;
clear all;
%%% Evaluation of distances for different angles
uc_fov = 6;
uc_fov_2 = uc_fov/2;
s1 = [0, 0];
s2 = [0, 0];
dmax = 10000;
s1_poly = flipud(int64([s1; circleArcToPolyline([s1, dmax, 90-uc_fov_2, uc_fov], 64)]));

distances = 100:1000:9100;
num_angles = 360;
pcuts = cell(num_angles, numel(distances));
angs = zeros(size(pcuts));
ds1 = zeros(size(pcuts));
ds2 = zeros(size(pcuts));
cnt = 1;
dist = distances(2);

%%%
for dist = distances
    %%
    circlepoints = round(circleArcToPolyline([0, dist, dist, -90, 180], num_angles))';
    pt = circlepoints(:,2);
    %%
    for pt = circlepoints
        %%
        ang = 180 + atan2d(pt(2)-dist,pt(1));
        angs(cnt) = ang - 90;
        s2_poly = flipud(int64([pt'; circleArcToPolyline([pt', dmax, ang-uc_fov_2, uc_fov], 64)]));
        pcuts{cnt} = bpolyclip(s1_poly', s2_poly', 1, true); 
%         figure, hold on, drawPolygon(s1_poly), drawPolygon(s2_poly), axis equal
%         figure, mb.drawPolygon(pcuts{1}),
%         figure, hold on, mb.drawPolygon(s1_pmoved'), mb.drawPolygon(s2_pmoved')
        %%
%         pcuts{cnt} = bpolyclip(s1_pmoved, s2_pmoved, 1, true);
        cnt = cnt + 1;
    end
end
%%
psize = arrayfun(@mb.polygonArea, pcuts)./(1000^2);
%%
[v, i] = findtwocrossings(psize, 1);

%%
plength = arrayfun(@mb.polygonLength, pcuts)./1000;
% [vpl, ipl] = findtwocrossings(plength);

qkelly = bsxfun(@rdivide, distances.^2, sin(deg2rad(angs)))./(1000^2);
qkelly(qkelly > 2.5e2) = nan;
[vqk, iqk] = findtwocrossings(qkelly, 90);
% %%
% figure, mesh(psize)
% 
% qd1d2pl = ds1+ds2;

qcust = repmat(((distances/dmax)+1).^2, num_angles, 1)./(1+sin(deg2rad(angs)));
[vqc, iqc] = findtwocrossings(qcust, 1.9);

qcust_1 = 1-(qcust/4);
[vqc1, iqc1] = findtwocrossings(qcust_1, 0.523);

% qcustmov = 1-(repmat((((distances-2000)/(dmax-2000))+1).^2, num_angles, 1)./(1+sin(deg2rad(angs)))/4);
qcust2 = 1-(repmat(((distances/dmax)).^2, num_angles, 1)./(sin(deg2rad(angs)))/2);
qcust2(qcust2 < 0) = nan;
[vqc2, iqc2] = findtwocrossings(qcust2, 0.55);

%%
markercolor = [0 0 0];
figure,
sz = {2,2};
plt = 1;
subplot(sz{:}, plt)
% mesh(ds1, ds2, psize);
% imagesc(psize);
plot(angs(:,1), psize); hold on;
line([0, 180], [1 1], 'color', markercolor);
ylim([0 2]);
title('polygon size for different angs and distances');
% axis off;
% 
plt = plt+1;
subplot(sz{:}, plt)
% mesh(ds1, ds2, qd1d2);
plot(angs(:,1), plength); 
title('polygon length for different angles and distances');


% axis off;
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

plt = plt+1;
subplot(sz{:}, plt)
% mesh(ds1, ds2, plength);
plot(angs(:,1), qkelly);
% ylim([0 5e8]);
line([0 180], [91 91], 'color', markercolor);
title('kelly quality for different angles and distances');

plt = plt+1;
subplot(sz{:}, plt)
% mesh(ds1, ds2, qd1d2);
plot(angs(:,1), qcust2); 
line([0 180], [0.55 0.55], 'color', markercolor);
ylim([0 1]);
title('custom gdop func for different angles and distances');


% plt = plt+1;
% subplot(sz{:}, plt)
% % mesh(ds1, ds2, qcust);
% % imagesc(qcust);
% plot(angs(:,1), qcust_1);
% line([0 180], [0.523 0.523], 'color', markercolor);
% title('custom gdop func for different angles and distances');
% % axis off



%% Evaluation of dist/angle
% figure, drawPolygon(s1_poly)
distances = 100:1000:9000;
dist = distances(1);
num_angles = 90;
pcut = cell(num_angles, numel(distances));
% angs = zeros(size(pcut));
cnt = 1;

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
