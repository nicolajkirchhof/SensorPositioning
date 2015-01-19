

%% IS THIS OLD???

%% Mage graphic
% scol = solarized;
col = repmat((0:10)', 1, 3)*0.1;

num_pts = 1000;
s1xy = [0 5];
s1rot = 0;
% s2xy = [15 19];
% s2rot = 270;
% dist = sqrt(sum((s2xy-s1xy).^2));
dist = 20;
fov = 25;
fov_2 = fov/2;
%%%
step = 12;
ang_places = (1:4)*step;
fun_bs_an = @(offset) mb.createAnnulusSegment(s1xy(1), s1xy(2), 0, dist, offset-fov, fov, num_pts)';
p_br = arrayfun(fun_bs_an, ang_places, 'uniformoutput', false);

fun_bs_an = @(offset, do) circleArcToPolyline([s1xy, dist+do, offset-fov, fov], num_pts);
p_br_annot = arrayfun(fun_bs_an, ang_places, 0.5*(1:numel(ang_places)), 'uniformoutput', false);


% fun_bs_an = @(offset) mb.createAnnulusSegment(s1xy(1), s1xy(2), 0, dist, offset-fov_2, fov, num_pts)';
% p_bl = arrayfun(fun_bs_an, 90+2*step:step:180-2*step, 'uniformoutput', false);
% 



% fun_ts_an = @(offset) mb.createAnnulusSegment(s2xy(1), s2xy(2), 0, dist, offset-fov_2, fov, num_pts)';
% step = 22.5;
% p_ts = arrayfun(fun_ts_an, step+180:step:360-step, 'uniformoutput', false);

fun_trans = @(p) cellfun(@(x) x', p, 'uniformoutput', false);
b_br = cellfun(@(x) x', p_br, 'uniformoutput', false);
% b_bl = cellfun(@(x) x', p_bl, 'uniformoutput', false);
b_all = [b_br];
combs = comb2unique(1:numel(b_all));
cuts = bpolyclip_batch(b_all, 1, combs, true);


cts = cuts(~cellfun(@isempty, cuts));
p_cuts = mb.boost2visilibity(cts);
% p_middle = p_cuts{15};

% rect_bnd = rectToPolygon([0 0 30 19]);
% b_bnd = bpolyclip_batch([{rect_bnd'}, b_all], 1, [ones(numel(b_all),1), (2:numel(b_all)+1)'], true);
b_bnd_up = mb.flattenPolygon(b_all);
p_bnd = fun_trans(b_bnd_up);


% sensor left marker
msize = 0.5;
arc_bm = circleArcToPolyline([s1xy, msize, -90, 180], num_pts); 
p_bm = [ s1xy; arc_bm];

% sensor left marker
% arc_tm = circleArcToPolyline([s2xy, msize, 180, 180], num_pts); 
% p_tm = [ s2xy; arc_tm];

%%%
cla, hold on, axis equal, axis off,
xlim([0 24]);
ylim([0 21]);
set(gcf, 'color', 'w');

vfov1 = text(21.5, 1, '$\Lambda_1$', 'horizontalalignment', 'center', 'verticalalignment', 'middle');
vfov2 = text(22, 6, '$\Lambda_2$', 'horizontalalignment', 'center', 'verticalalignment', 'middle');
vfov3 = text(22, 10, '$\Lambda_3$', 'horizontalalignment', 'center', 'verticalalignment', 'middle');
vfov4 = text(20.5, 15, '$\Lambda_4$', 'horizontalalignment', 'center', 'verticalalignment', 'middle');
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

%%%
% stmatlab2tikz('fig/sensoroverlap.tex');
Figures.makeFigure('Sensoroverlap');




