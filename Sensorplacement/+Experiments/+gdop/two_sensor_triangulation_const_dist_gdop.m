function two_sensor_triangulation_const_dist_gdop%(fov, max_dist, s1x, s2x,distance_factor)
% only function in order to keep workspace clean;
close all;
clear all;
import Experiments.gdop.*
%%% Evaluation of distances for different angles
uc_fov = 6;
uc_fov_2 = uc_fov/2;
s1 = [0, 0];
s2 = [0, 0];
dmax = 10000;
% s1_poly = flipud(int64([s1; circleArcToPolyline([s1, dmax, 90-uc_fov_2, uc_fov], 64)]));
s1_poly = flipud([s1; circleArcToPolyline([s1, dmax, 90-uc_fov_2, uc_fov], 64)]);
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
%     dist = distances(1);
    circlepoints = round(circleArcToPolyline([0, dist, dist, -90, 180], num_angles))';
    pt = circlepoints(:,2);
    %%
    for pt = circlepoints
        %%
        pt = circlepoints(:,320);
        ang = 180 + atan2d(pt(2)-dist,pt(1));
        angs(cnt) = ang - 90;
%         s2_poly = flipud(int64([pt'; circleArcToPolyline([pt', dmax, ang-uc_fov_2, uc_fov], 64)]));
s2_poly = flipud([pt'; circleArcToPolyline([pt', dmax, ang-uc_fov_2, uc_fov], 64)]);
        pcuts{cnt} = bpolyclip(s1_poly', s2_poly', 1, true); 
%         figure, hold on, axis equal
        cla, hold on, drawPolygon(s1_poly), drawPolygon(s2_poly), 
        mb.drawPolygon(pcuts{1}, 'k')
        ylim([50 150])
        xlim([-50 50])
%         figure, hold on, mb.drawPolygon(s1_pmoved'), mb.drawPolygon(s2_pmoved')
        %%
%         pcuts{cnt} = bpolyclip(s1_pmoved, s2_pmoved, 1, true);
        cnt = cnt + 1;
        
    end
end
%%%
psize = arrayfun(@mb.polygonArea, pcuts)./(1000^2);
%%%
pszline = 0.92;
[v, i] = findtwocrossings(psize, pszline);
myind = sub2ind(size(psize), i, [1:10;1:10]);
myind = myind(~isnan(myind));

pinterpoint = arrayfun(@mb.polygonInterpointDistances, pcuts, 'uniformoutput', false);
pinterpointmax = arrayfun(@(x) max(x{1}), pinterpoint)/1000;
pimxline = 1.5;
[vpi, ipi] = findtwocrossings(pinterpointmax, pimxline);
myind = sub2ind(size(psize), ipi, [1:10;1:10]);
myind = myind(~isnan(myind));


%%%
plength = arrayfun(@mb.polygonLength, pcuts)./1000;
% [vpl, ipl] = findtwocrossings(plength);

qkelly = bsxfun(@rdivide, distances.^2, sin(deg2rad(angs)))./(10000^2);
qkelly(qkelly > 1e2) = 1e2;
qkline = 0.84;
[vqk, iqk] = findtwocrossings(qkelly, qkline);
% %%
% figure, mesh(psize)
% 
% qd1d2pl = ds1+ds2;

% qcust = repmat(((distances/dmax)+1).^2, num_angles, 1)./(1+sin(deg2rad(angs)));
% [vqc, iqc] = findtwocrossings(qcust, 1.9);

% qcust_1 = 1-(qcust/4);
% [vqc1, iqc1] = findtwocrossings(qcust_1, 0.523);
%%%
% qcustmov = 1-(repmat((((distances-2000)/(dmax-2000))+1).^2, num_angles, 1)./(1+sin(deg2rad(angs)))/4);
% qcust2 = 1-(repmat(((distances/dmax)).^2, num_angles, 1)./(sin(deg2rad(angs)))/2);
% qcust2 = 1-(repmat((distances.^2/dmax.^2), num_angles, 1)./(sin(deg2rad(angs)))/2);
qcust2 = 1-(qkelly./2);
qcust2(qcust2 < 0) = -1;
qcline = 0.58;
[vqc2, iqc2] = findtwocrossings(qcust2, qcline);
%%
% qcust3 = 1-(repmat(((distances/dmax)).^2, num_angles, 1)./(sin(deg2rad(angs))));
% qcust3(qcust3 < -10) = nan;
% [vqc2, iqc2] = findtwocrossings(qcust3, 0.2);

%%

markercolor = [0 0 0];
figure;
% sz = {2,2};
% plt = 1;
% h_sp1 = subplot(sz{:}, plt);
cla;
hold on;
handles = plot(angs(:,1), psize); 
line([0, 180], [pszline pszline], 'color', markercolor);
ylim([0 2]);
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
end
title('a) Polygon sizes vs angles');
xlabel('Inner bearing angle $[^{\circ}]$');
ylabel('Size $[m^2]$');
xlim([0 180]);
% matlab2tikz('export/QualityKellyVsCustom_1.tikz', 'parseStrings', false);
%%
figure;
% plt = plt+1;
% subplot(sz{:}, plt)
cla;
handles = plot(angs(:,1), pinterpointmax);
ylim([0 4]);
xlim([0 180]);
line([0, 180], [pimxline pimxline], 'color', markercolor);
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
end
title('b) Max polygon interpoint distance');
% xlabel('Inner bearing angle $[^{\circ}]$');
ylabel('Size $m$');
matlab2tikz('export/QualityKellyVsCustom_2.tikz', 'parseStrings', false);
%%
figure;
% plt = plt+1;
% subplot(sz{:}, plt)
cla;
handles = plot(angs(:,1), qkelly);
ylim([0 2]);
xlim([0 180]);
line([0 180], [qkline qkline], 'color', markercolor);
title('c) Kelly quality');
xlabel('Inner bearing angle $[^{\circ}]$');
ylabel('Quality');
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
end
% matlab2tikz('export/QualityKellyVsCustom_3.tikz', 'parseStrings', false);
%%
figure;
% plt = plt+1;
% subplot(sz{:}, plt)
cla;
handles = plot(angs(:,1), qcust2); 
line([0 180], [qcline qcline], 'color', markercolor);
ylim([0 1]);
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
end
xlim([0 180]);
title('d) Custom gdop function');
xlabel('Inner bearing angle $[^{\circ}]$');
ylabel('Quality');
% matlab2tikz('export/QualityKellyVsCustom_4.tikz', 'parseStrings', false);

%%
flti = 40:320; fltj = 1:9; psizeflt = psize(flti, fltj); qkellyflt = qkelly(flti, fltj);
% figure, hold on, plot(psizeflt), plot(qkellyflt)
fun_pdiffflt = @(x) psizeflt-x.*qkellyflt;
offset = fminsearch(@(x) sum(sum(fun_pdiffflt(x).^2)), 1);
pdiffflt = fun_pdiffflt(offset);
% figure, plot(pdiffflt);


%%%

flti = 120:240; fltj = 1:9; pipmxflt = pinterpointmax(flti, fltj); qkellyflt2 = qkelly(flti, fltj);
% figure, hold on, plot(pipmxflt), plot(qkellyflt2)
fun_pdiffflt2 = @(x) pipmxflt-x.*qkellyflt2;
offset2 = fminsearch(@(x) sum(sum(fun_pdiffflt2(x).^2)), 1);
pdiffflt2 = fun_pdiffflt2(offset2);
% % figure, plot(pdiffflt2);
% figure,hold on; plot(angs(flti,1), pipmxflt), plot(angs(flti,1), offset2.*qkellyflt2); 

%%
figure,
% sz = {2,2};
% plt = 1;
% subplot(sz{:}, plt)
cla;
hold on;
handles = plot(angs(:,1), psize); 
handles2 = plot(angs(:,1), offset.*qkelly, 'linestyle', '--');
line([0, 180], offset*[pszline pszline], 'color', 'k');
ylim([0 2]);
xlim([0 180]);
ylabel('Quality');
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
    set(handles2(idh), 'color', colors(idh, :));
end
title('Polygon size vs fitted Kelly quality.');
matlab2tikz('export/QualityKellyVsProperties_1.tikz', 'parseStrings', false);

figure;
% plt = plt+1;
% subplot(sz{:}, plt);
cla;
hold on;
handles = plot(angs(:,1), psize-offset.*qkelly); 
% plot(angs(:,1), offset.*qkelly)
% line([0, 180], [pszline pszline], 'color', markercolor);
ylim([-2 2]);
xlim([0 180]);
ylabel('Quality');
title('Difference of polygon size and fitted Kelly');
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
%     set(handles2(idh), 'color', colors(idh, :));
end
matlab2tikz('export/QualityKellyVsProperties_2.tikz', 'parseStrings', false);
%%
figure,
% plt = plt+1;
% subplot(sz{:}, plt);
cla;
hold on;
handles = plot(angs(:,1), pinterpointmax(:, 2:2:end)); 
handles2 = plot(angs(:,1), offset2.*qkelly(:,2:2:end), 'linestyle', '--');
line([0, 180], (offset2/offset)*[pszline pszline], 'color', 'k');
ylim([0 6]);
xlim([0 180]);
ylabel('Quality');
title('Polygon size vs fitted Kelly quality');
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
    set(handles2(idh), 'color', colors(idh, :));
end
matlab2tikz('export/QualityKellyVsProperties_3.tikz', 'parseStrings', false);
%%
figure,
% plt = plt+1;
% subplot(sz{:}, plt);
cla;
hold on;
handles = plot(angs(:,1), pinterpointmax(:, 2:2:end)-offset2.*qkelly(:, 2:2:end)); 
% plot(angs(:,1), offset.*qkelly)
line([0, 180], [0 0], 'color', markercolor);
ylim([-4 4]);
xlim([0 180]);
ylabel('Quality');
title('Difference polygon size vs fitted Kelly quality');
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
%     set(handles2(idh), 'color', colors(idh, :));
end
xlabel('Inner bearing angle $[^{\circ}]$');
matlab2tikz('export/QualityKellyVsProperties_4.tikz', 'parseStrings', false);


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
title('polygon size for different d1 ds at 90�');
axis off;

plt = plt+1;
subplot(sz{:}, plt)
% mesh(ds1, ds2, qd1d2);
imagesc(qd1d2);
title('quality (d1*d2) for different distances at 90�');
axis off;
% plt = plt+1;
% subplot(sz{:}, plt)
% % mesh(ds1, ds2, pidmax);
% imagesc(pidmax);
% title('max ip dist for different distances at 90�');

% plt = plt+1;
% subplot(sz{:}, plt)
% % mesh(ds1, ds2, pidmax);
% imagesc(pidmean);
% title('mean ip dist for different distances at 90�');

% plt = plt+1;
% subplot(sz{:}, plt)
% % mesh(ds1, ds2, pidmax);
% imagesc(qd1d2pl);
% title('ds1 + ds2 plus for different distances at 90�');
% 
% 
% plt = plt+1;
% subplot(sz{:}, plt)
% % mesh(ds1, ds2, plength);
% imagesc(plength);
% title('polygon length for different distances at 90�');

plt = plt+1;
subplot(sz{:}, plt)
% mesh(ds1, ds2, qcust);
imagesc(qcust);
title('custom range func for different distances at 90�');
axis off

%%
