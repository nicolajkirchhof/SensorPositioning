%% Mage graphic
% scol = solarized;
col = repmat((0:10)', 1, 3)*0.1;

num_pts = 2500;
s1xy = [0 5];
s1rot = 0;
dist = 20;
fov = 13;
fov_2 = fov/2;
%%%
step = 6;
ang_places = ((1:4)*step)-8;
fun_bs_an = @(offset) mb.createAnnulusSegment(s1xy(1), s1xy(2), 0, dist, offset-fov, fov, num_pts)';
p_br = arrayfun(fun_bs_an, ang_places, 'uniformoutput', false);

fun_bs_an = @(offset, do) circleArcToPolyline([s1xy, dist+do, offset-fov, fov], num_pts);
p_br_annot = arrayfun(fun_bs_an, ang_places, 0.5*(1:numel(ang_places)), 'uniformoutput', false);


fun_trans = @(p) cellfun(@(x) x', p, 'uniformoutput', false);
b_br = cellfun(@(x) x', p_br, 'uniformoutput', false);
b_all = [b_br];
combs = comb2unique(1:numel(b_all));
cuts = bpolyclip_batch(b_all, 1, combs, true);


cts = cuts(~cellfun(@isempty, cuts));
p_cuts = mb.boost2visilibity(cts);
b_bnd_up = mb.flattenPolygon(b_all);
p_bnd = fun_trans(b_bnd_up);


% sensor left marker
msize = 0.5;
arc_bm = circleArcToPolyline([s1xy, msize, -90, 180], num_pts); 
p_bm = [ s1xy; arc_bm];


%%%
cla, hold on, axis equal, axis off,
xlim([0 24]);
ylim([-1 12]);
set(gcf, 'color', 'w');

vfov1 = text('Interpreter', 'none', 'string', '$\Lambda_1$');
vfov2 = text('Interpreter', 'none', 'string', '$\Lambda_2$');
vfov3 = text('Interpreter', 'none', 'string', '$\Lambda_3$');
vfov4 = text('Interpreter', 'none', 'string', '$\Lambda_4$');
%
set(vfov1, 'position', [20.5 0.5]);
set(vfov2, 'position', [21.3 2.8]);
set(vfov3, 'position', [22 5]);
set(vfov4, 'position', [22.3 7.5]);
%

fillPolygon(p_br([1,4]), col(10,:))
fillPolygon(p_cuts([1,3,5]), col(7,:));
fillPolygon(p_cuts([2,4]), col(4,:));
drawPolygon(p_bnd, 'color', col(1,:));
drawPolyline(p_br_annot, 'color',col(1,:) );

% mb.numberRings(p_cuts);
% fillPolygon(p_middle, col(2,:));
% drawPolygon(rect_bnd, 'color', col(1,:));
fillPolygon(p_bm, 'k');
% fillPolygon(p_tm, 'k');

matlab2tikz('fig/sensoroverlap_content.tex');
%%