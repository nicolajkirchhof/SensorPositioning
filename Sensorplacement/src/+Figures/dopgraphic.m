%% Mage graphic
scol = solarized;
num_pts = 1000;
s1xy = [15 0];
s1rot = 0;
s2xy = [15 19];
s2rot = 180;
arc_ll = circleArcToPolyline([s1xy, 15, s1rot, 180], num_pts); 
arc_llin = circleArcToPolyline([s1xy, 14, s1rot, 180], num_pts);
p_ll = [ arc_ll; flipud(arc_llin)];

% arc left short
arc_ls = circleArcToPolyline([s1xy, 10, s1rot, 180], num_pts); 
arc_lsin = circleArcToPolyline([s1xy, 9, s1rot, 180], num_pts); 
p_ls = [ arc_ls; flipud(arc_lsin)];

% sensor left marker
msize = 0.5;
arc_lm = circleArcToPolyline([s1xy, msize, s1rot, 180], num_pts); 
p_lm = [ s1xy; arc_lm];

arc_rl = circleArcToPolyline([s2xy, 15, s2rot, 180], num_pts); 
arc_rlin = circleArcToPolyline([s2xy, 14, s2rot, 180], num_pts); 
p_rl = [ arc_rl; flipud(arc_rlin)];

arc_rs = circleArcToPolyline([s2xy, 10, s2rot, 180], num_pts); 
arc_rsin = circleArcToPolyline([s2xy, 9, s2rot, 180], num_pts); 
p_rs = [ arc_rs; flipud(arc_rsin)];

% sensor left marker
arc_rm = circleArcToPolyline([s2xy, msize, s2rot, 180], num_pts); 
p_rm = [ s2xy; arc_rm];

rect_bnd = rectToPolygon([0 0 30 19]);
combs = comb2unique(1:4);

cuts = bpolyclip_batch({p_ll', p_ls', p_rl', p_rs'}, 1, combs, true);
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
drawPolygon(p_ll, 'color', scol.base0);
drawPolygon(p_rl, 'color', scol.base0);
drawPolygon(p_rs, 'color', scol.base0);
drawPolygon(p_ls, 'color', scol.base0);
fillPolygon(p_lm, 'k');
fillPolygon(p_rm, 'k');
fillPolygon(p_cuts, scol.base0);
fillPolygon(p_middle, ones(1,3)*0.2);
drawPolygon(rect_bnd, 'color', ones(1,3)*0.1);
% plot
% set(gca, 'cameraUpVector', [0 1 0]);
% matlab2tikz('fig/doptriag/doptriang.tex');
% mb.numberRings(p_cuts);

%%
cla, hold on, axis equal;
drawPolyline(arc_ll);
drawPolyline(arc_llin);
drawPolyline(arc_ls);
drawPolyline(arc_lsin);
drawPolyline(arc_rl);
drawPolyline(arc_rlin);
drawPolyline(arc_rs);
drawPolyline(arc_rsin);



