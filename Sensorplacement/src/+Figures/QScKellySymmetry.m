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
cnti = 1;
cntj = 1;
dist = distances(2);
colors = flipud(repmat(linspace(0,0.7,numel(distances))', 1, 3));

cnt_plt = [1:10]*36;
figure, hold on, axis equal;
mb.drawPolygon(s1_poly/1000, 'color', [0, 0, 0]);
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
            mb.drawPolygon(s2_poly/1000, 'color', colors(cntj, :), 'linestyle', '--');
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