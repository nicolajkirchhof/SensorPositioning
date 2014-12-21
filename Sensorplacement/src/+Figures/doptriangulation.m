%% Mage graphic
% scol = solarized;
col = repmat((0:10)', 1, 3)*0.1;

num_pts = 1000;
s1xy = [15 0];
s1rot = 90;
s2xy = [15 19];
s2rot = 270;
dist = sqrt(sum((s2xy-s1xy).^2));
fov = 6;
fov_2 = fov/2;
%%%
fun_bs_an = @(offset) mb.createAnnulusSegment(s1xy(1), s1xy(2), 0, dist, offset-fov_2, fov, num_pts)';
step = 22.5;
p_bs = arrayfun(fun_bs_an, step:step:180-step, 'uniformoutput', false);

fun_ts_an = @(offset) mb.createAnnulusSegment(s2xy(1), s2xy(2), 0, dist, offset-fov_2, fov, num_pts)';
step = 22.5;
p_ts = arrayfun(fun_ts_an, step+180:step:360-step, 'uniformoutput', false);

fun_trans = @(p) cellfun(@(x) x', p, 'uniformoutput', false);
b_ts = cellfun(@(x) x', p_ts, 'uniformoutput', false);
b_bs = cellfun(@(x) x', p_bs, 'uniformoutput', false);
b_all = [b_ts, b_bs];
combs = comb2unique(1:numel(b_all));
cuts = bpolyclip_batch(b_all, 1, combs, true);

cts = cuts(~cellfun(@isempty, cuts));
p_cuts = mb.boost2visilibity(cts);
p_middle = p_cuts{15};

rect_bnd = rectToPolygon([0 0 30 19]);
b_bnd = bpolyclip_batch([{rect_bnd'}, b_all], 1, [ones(numel(b_all),1), (2:numel(b_all)+1)'], true);
b_bnd_up = mb.flattenPolygon(b_bnd);
p_bnd = fun_trans(b_bnd_up);

% sensor left marker
msize = 0.5;
arc_bm = circleArcToPolyline([s1xy, msize, 0, 180], num_pts); 
p_bm = [ s1xy; arc_bm];

% sensor left marker
arc_tm = circleArcToPolyline([s2xy, msize, 180, 180], num_pts); 
p_tm = [ s2xy; arc_tm];

%%%
cla, hold on, axis equal, axis off,
set(gca, 'color', 'w');
% drawPolygon(p_bnd, 'color', col(5,:));

% fillPolygon(p_cuts, col(7,:));
% mb.numberRings(p_cuts);
% fillPolygon(p_middle, col(2,:));
% drawPolygon(rect_bnd, 'color', col(1,:));
fillPolygon(p_bm, 'k');
fillPolygon(p_tm, 'k');

matlab2tikz('fig/doptriag/doptriangulation.tex');
%%
drawPolygon(p_bm);
drawPolygon(p_br);
drawPolygon(p_tl);
drawPolygon(p_tm);
drawPolygon(p_tr);

%%

% arc left short
arc_ls = circleArcToPolyline([s1xy, 10, s1rot, 180], num_pts); 
arc_lsin = circleArcToPolyline([s1xy, 9, s1rot, 180], num_pts); 
p_ls = [ arc_ls; flipud(arc_lsin)];



arc_tl = circleArcToPolyline([s2xy, 15, s2rot, 180], num_pts); 
arc_rlin = circleArcToPolyline([s2xy, 14, s2rot, 180], num_pts); 
p_tl = [ arc_tl; flipud(arc_rlin)];

arc_rs = circleArcToPolyline([s2xy, 10, s2rot, 180], num_pts); 
arc_rsin = circleArcToPolyline([s2xy, 9, s2rot, 180], num_pts); 
p_rs = [ arc_rs; flipud(arc_rsin)];





%
cuts = bpolyclip_batch({p_bl', p_ls', p_tl', p_rs'}, 1, combs, true);
cts = cuts(~cellfun(@isempty, cuts));
p_cuts = mb.boost2visilibity(cts);
p_middle = p_cuts{7};

%%%
for fn = fieldnames(scol)'
    fn = fn{1};
    scol.(fn) = rgb2gray(scol.(fn));
    fprintf(1, 'color %s = %g %g %g \n', fn, scol.(fn));
end
%%%
% scol = solarized;
cla, hold on, axis equal, axis off,
set(gca, 'color', 'w');
drawPolygon(p_bl, 'color', scol.base0);
drawPolygon(p_tl, 'color', scol.base0);
drawPolygon(p_rs, 'color', scol.base0);
drawPolygon(p_ls, 'color', scol.base0);
fillPolygon(p_bm, 'k');
fillPolygon(p_tm, 'k');
fillPolygon(p_cuts, scol.base0);
fillPolygon(p_middle, ones(1,3)*0.2);
drawPolygon(rect_bnd, 'color', ones(1,3)*0.1);
% plot
% set(gca, 'cameraUpVector', [0 1 0]);
matlab2tikz('fig/doptriag/doptriang.tex');
% mb.numberRings(p_cuts);

%%
cla, hold on, axis equal;
drawPolyline(arc_bl);
drawPolyline(arc_llin);
drawPolyline(arc_ls);
drawPolyline(arc_lsin);
drawPolyline(arc_tl);
drawPolyline(arc_rlin);
drawPolyline(arc_rs);
drawPolyline(arc_rsin);



