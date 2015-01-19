%% Mage graphic
%%%
cla
clear variables
col = repmat((0:10)', 1, 3)*0.1;

num_pts = 1000;
s1xy = [15 0];
s1rot = 0;
s2xy = [15 19];
s2rot = 180;
dist = sqrt(sum((s2xy-s1xy).^2));
fov = 6;
fov_2 = fov/2;

%
% arc left short
arc_ls = circleArcToPolyline([s1xy, 15, s1rot, 180], num_pts); 
arc_lsin = circleArcToPolyline([s1xy, 14, s1rot, 180], num_pts); 
p_bs = [ arc_ls; flipud(arc_lsin)];

arc_ls = circleArcToPolyline([s1xy, 10, s1rot, 180], num_pts); 
arc_lsin = circleArcToPolyline([s1xy, 9, s1rot, 180], num_pts); 
p_ls = [ arc_ls; flipud(arc_lsin)];

arc_tl = circleArcToPolyline([s2xy, 15, s2rot, 180], num_pts); 
arc_rlin = circleArcToPolyline([s2xy, 14, s2rot, 180], num_pts); 
p_tl = [ arc_tl; flipud(arc_rlin)];

arc_rs = circleArcToPolyline([s2xy, 10, s2rot, 180], num_pts); 
arc_rsin = circleArcToPolyline([s2xy, 9, s2rot, 180], num_pts); 
p_rs = [ arc_rs; flipud(arc_rsin)];

b_all = {p_bs', p_ls', p_tl', p_rs'};
combs = comb2unique(1:numel(b_all));
cuts = bpolyclip_batch(b_all, 1, combs, true);

cts = cuts(~cellfun(@isempty, cuts));
p_cuts = mb.boost2visilibity(cts);
p_middle = p_cuts{7};

% sensor left marker
msize = 0.5;
arc_bm = circleArcToPolyline([s1xy, msize, 0, 180], num_pts); 
p_bm = [ s1xy; arc_bm];

% sensor left marker
arc_tm = circleArcToPolyline([s2xy, msize, 180, 180], num_pts); 
p_tm = [ s2xy; arc_tm];
%%%
%%%
% for fn = fieldnames(scol)'
%     fn = fn{1};
%     scol.(fn) = rgb2gray(scol.(fn));
%     fprintf(1, 'color %s = %g %g %g \n', fn, scol.(fn));
% end
%%%
% scol = solarized;
cla, hold on, axis equal, axis off,
set(gca, 'color', 'w');
fillPolygon(p_bs, 'k', 'facealpha', 0.3);
fillPolygon(p_ls, 'k', 'facealpha', 0.3);
fillPolygon(p_tl, 'k', 'facealpha', 0.3);
fillPolygon(p_rs, 'k', 'facealpha', 0.3);

% fillPolygon(p_bm, 'k', 'facealpha', 0.5);
% fillPolygon(p_tm, 'k');
fillPolygon(p_cuts, 'k', 'facealpha', 0.5);
% fillPolygon(p_middle, ones(1,3)*0.2);
% drawPolygon(rect_bnd, 'color', ones(1,3)*0.1);
fillPolygon(p_bm, 'k');
fillPolygon(p_tm, 'k');
% axis on;
xlim([-0 30]);
ylim([-0 19]);
% matlab2tikz('fig/doptriag/doptriang.tex');
% mb.numberRings(p_cuts);
Figures.makeFigure('Doptrilateration', '8.2895cm', '5.25cm');

