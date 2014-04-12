%% Mage graphic
% scol = solarized;
col = repmat((0:10)', 1, 3)*0.1;

num_pts = 1000;
s1xy = [1 1];
s1rot = 23;
s2xy = [5 1];
s2rot = 113;
dist = sqrt(sum((s2xy-s1xy).^2));
fov = 23;
fov_2 = fov/2;
p1xy = [3 3];
%%%
step = 22.5;
fun_bs_an = @(offset) mb.createAnnulusSegment(s1xy(1), s1xy(2), 0, dist, offset-fov_2, fov, num_pts)';
% p_bs = arrayfun(fun_bs_an, step:step:180-step, 'uniformoutput', false);
p_bs = arrayfun(fun_bs_an, s1rot+step, 'uniformoutput', false);

fun_ts_an = @(offset) mb.createAnnulusSegment(s2xy(1), s2xy(2), 0, dist, offset-fov_2, fov, num_pts)';
step = 22.5;
% p_ts = arrayfun(fun_ts_an, step+180:step:360-step, 'uniformoutput', false);
p_ts = arrayfun(fun_ts_an, s2rot+step, 'uniformoutput', false);

fun_trans = @(p) cellfun(@(x) x', p, 'uniformoutput', false);
b_ts = cellfun(@(x) x', p_ts, 'uniformoutput', false);
b_bs = cellfun(@(x) x', p_bs, 'uniformoutput', false);
b_all = [b_ts, b_bs];
combs = comb2unique(1:numel(b_all));
cuts = bpolyclip_batch(b_all, 1, combs, true);

cts = cuts(~cellfun(@isempty, cuts));
p_cuts = mb.boost2visilibity(cts);
% p_middle = p_cuts{15};

rect_bnd = rectToPolygon([0 0 30 19]);
b_bnd = bpolyclip_batch([{rect_bnd'}, b_all], 1, [ones(numel(b_all),1), (2:numel(b_all)+1)'], true);
b_bnd_up = mb.flattenPolygon(b_bnd);
p_bnd = fun_trans(b_bnd_up);

% sensor left marker
% msize = 0.1;
% arc_bm = circleArcToPolyline([s1xy, msize, 0, 360], num_pts); 
% p_bm = [ s1xy; arc_bm];

% sensor left marker
% arc_tm = circleArcToPolyline([s2xy, msize, 0, 360], num_pts); 
% p_tm = [ s2xy; arc_tm];

%%%
cla, hold on, axis equal, axis off
xlim([0 6]);
ylim([0 5]);
set(gca, 'YTick', 0:5);
set(gca, 'color', 'w');



text('Interpreter', 'none', 'position', s1xy+[-0.2 -0.2], 'string', 'S_1 = (x, y, \phi)')
text('Interpreter', 'none', 'position', s2xy+[-0.2 -0.2], 'string', 'S_2 = (x, y, \phi)')

text('Interpreter', 'none', 'position', [2 1.5], 'string', 'vfov1');
text('Interpreter', 'none', 'position', [3.5 1.5], 'string', 'vfov2')

text('Interpreter', 'none', 'position', [1.5 4], 'string', 'd1');
text('Interpreter', 'none', 'position', [3.8 4], 'string', 'd2')

text('Interpreter', 'none', 'position', p1xy+[-0.1 -0.3], 'string', 'O')

fillPolygon(p_bnd, col(10,:));
drawPolygon(p_bnd, 'color', col(6,:));
fillPolygon(p_cuts, col(7,:));

% mb.numberRings(p_cuts);
% fillPolygon(p_middle, col(2,:));
% drawPolygon(rect_bnd, 'color', col(1,:));
drawPoint(s1xy, 'marker', 'o','MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'markersize', 10);
drawPoint(s2xy, 'marker', 'o', 'MarkerEdgeColor', 'k','MarkerFaceColor', 'k', 'markersize', 10);
drawPoint(p1xy, 'marker', 'x','MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'markersize', 10, 'LineWidth', 3, 'color', col(2,:));

lcon = [s1xy; p1xy; s2xy];
plot(lcon(:,1),lcon(:,2), 'LineWidth', 2, 'color', col(2,:));

ang1 = -pi + angle2Points(s1xy, p1xy);
anginner = angle3Points(s1xy, p1xy, s2xy);

%
seg_ang = circleArcToPolyline([p1xy, 0.5, rad2deg(ang1), rad2deg(anginner)], num_pts);
hseg_ang = drawPolyline(seg_ang);
set(hseg_ang, 'color', 'k')
%%
cla
seg_ang_s1 = circleArcToPolyline([s1xy, 1, s1rot+fov_2, fov], num_pts);
hseg_ang_s1 = drawPolyline(seg_ang_s1);
set(hseg_ang_s1, 'color', 'k')

seg_ang_s2 = circleArcToPolyline([s2xy, 1, s2rot+fov_2, fov], num_pts);
hseg_ang_s2 = drawPolyline(seg_ang_s2);
set(hseg_ang_s2, 'color', 'k')
% delete(hseg_ang);
% fillPolygon(p_bm, 'k');
% fillPolygon(p_tm, 'k');

% matlab2tikz('fig/sensormodel.tex');
matlab2tikz('fig/sensormodel_circles.tex');
