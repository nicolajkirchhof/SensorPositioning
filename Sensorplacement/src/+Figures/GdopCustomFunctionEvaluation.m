function two_sensor_triangulation_const_dist_gdop%(fov, max_dist, s1x, s2x,distance_factor)
% only function in order to keep workspace clean;
close all;
clearvars -except all_eval*
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
cnti = 1;
cntj = 1;
dist = distances(2);
colors = flipud(repmat(linspace(0,0.7,numel(distances))', 1, 3));

cnt_plt = [1:10]*36;
figure, hold on, axis equal;
% mb.drawPolygon(s1_poly/1000, 'color', [0, 0, 0]);
mb.fillPolygon(s1_poly/1000, 'k', 'facealpha', 0.3);
drawPoint(s1/1000, 'color', [0, 0, 0], 'markersize', 6, 'markerfacecolor', [0, 0, 0]);
%%%
for dist = distances
    %%
%     dist = distances(1);
    circlepoints = round(circleArcToPolyline([0, dist, dist, -90, 180], num_angles))';
    h = drawEdge(circlepoints(:, 1:end-1)'/1000, circlepoints(:, 2:end)'/1000);
    set(h, 'color', colors(cntj, :));
    drawPoint(s1+[0 dist]/1000, 'marker', 'x', 'markersize', 6, 'color', [0, 0, 0]);
    pt = circlepoints(:,2);
    %%
    for pt = circlepoints
        %%
%         pt = circlepoints(:,320);
        ang = 180 + atan2d(pt(2)-dist,pt(1));
        angs(cnti, cntj) = ang - 90;
%         s2_poly = flipud(int64([pt'; circleArcToPolyline([pt', dmax, ang-uc_fov_2, uc_fov], 64)]));
        s2_poly = flipud([pt'; circleArcToPolyline([pt', dmax, ang-uc_fov_2, uc_fov], 64)]);
        pcuts{cnti, cntj} = bpolyclip(s1_poly', s2_poly', 1, true); 
        if cnt_plt(cntj) == cnti
%             mb.drawPolygon(s2_poly/1000, 'color', colors(cntj, :), 'linestyle', '--');
            mb.fillPolygon(s2_poly/1000, 'k', 'facealpha', 0.3);
            drawPoint(pt'/1000, 'color', [0, 0, 0], 'markersize', 6, 'markerfacecolor', [0, 0, 0]);
        end
%         figure, hold on, axis equal
%         cla, hold on, drawPolygon(s1_poly), drawPolygon(s2_poly), 
%         mb.drawPolygon(pcuts{1}, 'k')
%         ylim([50 150])
%         xlim([-50 50])
%         figure, hold on, mb.drawPolygon(s1_pmoved'), mb.drawPolygon(s2_pmoved')
        %%
%         pcuts{cnt} = bpolyclip(s1_pmoved, s2_pmoved, 1, true);
        cnti = cnti + 1;
        
    end
    cnti = 1;
    cntj = cntj+1;
end
%%%
% % title('Polygon evaluation szenario');
% xlabel('$[m]$');
% ylabel('$[m]$');
% ylim([-500, 18500]/1000);
% xlim([-7500, 10000]/1000);
% % filename = 'PolygonEvaluationSzenario';
% Figures.makeFigure('PolygonEvaluationSzenario', '9cm');
%%%
psize = arrayfun(@mb.polygonArea, pcuts)./(1000^2);
%%% code for figureing the crossings with the functions
% pszline = 0.92;
% pszline = 1;
% [v, i] = findtwocrossings(psize, pszline);
% myind = sub2ind(size(psize), i, [1:10;1:10]);
% myind = myind(~isnan(myind));

pinterpoint = arrayfun(@mb.polygonInterpointDistances, pcuts, 'uniformoutput', false);
pinterpointmax = arrayfun(@(x) max(x{1}), pinterpoint)/1000;

qkelly = bsxfun(@rdivide, distances.^2, sin(deg2rad(angs)))./(dmax^2);
qkelly(qkelly > 1e2) = 1e2;

dist_norm = min(distances/dmax, ones(size(distances)));
qcust2 = 1-(bsxfun(@rdivide, dist_norm.^2, sin(deg2rad(angs))));
qcust2(qcust2 < 0) = 0;

% [vqc2, iqc2] = findtwocrossings(qcust2, qcline);

%%% Match the polygon size and interpoint distances to qkelly function
flti = 40:320; fltj = 1:9; psizeflt = psize(flti, fltj); qkellyflt = qkelly(flti, fltj);
% figure, hold on, plot(psizeflt), plot(qkellyflt)
fun_pdiffflt = @(x) psizeflt-x.*qkellyflt;
offset = fminsearch(@(x) sum(sum(fun_pdiffflt(x).^2)), 1);
% offset is 1.108398, 1/offset is 0.902203
pdiffflt = fun_pdiffflt(offset);
% figure, plot(pdiffflt);

%%%
flti = 120:240; fltj = 1:9; pipmxflt = pinterpointmax(flti, fltj); qkellyflt2 = qkelly(flti, fltj);
% figure, hold on, plot(pipmxflt), plot(qkellyflt2)
fun_pdiffflt2 = @(x) pipmxflt-x.*qkellyflt2;
offset2 = fminsearch(@(x) sum(sum(fun_pdiffflt2(x).^2)), 1);
% offset2 is 2.439160 1/offset2 is 0.409977
pdiffflt2 = fun_pdiffflt2(offset2);
% % figure, plot(pdiffflt2);
% figure,hold on; plot(angs(flti,1), pipmxflt), plot(angs(flti,1), offset2.*qkellyflt2); 
pszline = 0.5; % set polygon area to one

qkline = pszline/offset; % = 0.902203, qkelly definition relative to defined polygon area

pimxline = qkline * offset2; % = 2.200617, qkelly line tranfered to interpoint distance

qcline = 1-qkline; % =
markercolor = [0 0 0];
%%
cla;
handles = plot(angs(:,1), qcust2); 
line([0 180], [qcline qcline], 'color', [0 0 0]);
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
end
ylim([0 1]);
xlim([0 180]);
% title('d) Custom gdop function');
xlabel('Inner bearing angle $[^{\circ}]$');
ylabel('Quality');
%%%
filename = 'ScQKellyVsQualityFunction.tex';
% Figures.makeFigure(filename, [], '5cm');
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '5cm',...
    'width', '10cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);

Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);

%%
cla;
hold on;
handles = plot(angs(:,1), psize./offset); 
handles2 = plot(angs(:,1), qkelly, 'linestyle', '--');
line([0, 180], [pszline pszline]./offset, 'color', 'k');
ylim([0 2]);
xlim([0 180]);
ylabel('$[m^2]$, $H^{sc}$');
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
    set(handles2(idh), 'color', colors(idh, :));
end
xlabel('Inner bearing angle $[^{\circ}]$');
filename = 'ScQKellyVsPolygonArea.tex';
% Figures.makeFigure(filename, [], '5cm');
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '5cm',...
    'width', '10cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);
%%
cla;
hold on;
handles = plot(angs(:,1), psize./offset-qkelly); 
% plot(angs(:,1), offset.*qkelly)
% line([0, 180], [pszline pszline], 'color', markercolor);
ylim([-1 1]);
xlim([0 180]);
ylabel('$[m^2]$, $H^{sc}$');
% title('b) Difference of polygon size and fitted Kelly');
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
%     set(handles2(idh), 'color', colors(idh, :));
end
xlabel('Inner bearing angle $[^{\circ}]$');
filename = 'ScQKellyVsPolygonAreaDiff.tex';
% Figures.makeFigure(filename, [], '5cm');
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '5cm',...
    'width', '10cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);
%%
cla;
hold on;
handles = plot(angs(:,1), pinterpointmax(:, 2:2:end)./offset2); 
handles2 = plot(angs(:,1), qkelly(:,2:2:end), 'linestyle', '--');
line([0, 180], (offset2/offset)*[pszline pszline], 'color', 'k');
ylim([0 3]);
xlim([0 180]);
ylabel('$[m]$, $H^{sc}$');
% title('a) Maximum interpoint distance vs fitted Kelly quality');
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
    set(handles2(idh), 'color', colors(idh, :));
end
xlabel('Inner bearing angle $[^{\circ}]$');
filename = 'ScQKellyVsInterpointDistance.tex';
% Figures.makeFigure(filename, [], '5cm');
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '5cm',...
    'width', '10cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);
%%
cla;
hold on;
handles = plot(angs(:,1), pinterpointmax(:, 2:2:end)-offset2.*qkelly(:, 2:2:end)); 
% plot(angs(:,1), offset.*qkelly)
line([0, 180], [0 0], 'color', [0 0 0]);
ylim([-4 4]);
xlim([0 180]);
ylabel('$[m]$, $H^{sc}$');
% title('b) Difference of maximum interpoint distance vs fitted Kelly quality');
colors = flipud(repmat(linspace(0,0.7,numel(handles))', 1, 3));
for idh = 1:numel(handles)
    set(handles(idh), 'color', colors(idh, :));
%     set(handles2(idh), 'color', colors(idh, :));
end
xlabel('Inner bearing angle $[^{\circ}]$');
filename = 'ScQKellyVsInterpointDistanceDiff.tex';
% Figures.makeFigure(filename, [], '5cm');
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '5cm',...
    'width', '10cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);
%%
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
% matlab2tikz('export/QualityKellyVsCustom_2.tikz', 'parseStrings', false);
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

