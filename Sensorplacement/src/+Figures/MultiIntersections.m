%% Mage graphic
% scol = solarized;
col = repmat((0:10)', 1, 3)*0.1;

num_pts = 1000;
s1xy = [1 1];
s1rot = 22.5;
s2xy = [5 1];
s2rot = 113;

s3xy = [1 2];
s3rot = 0;
% dist = sqrt(sum((s2xy-s1xy).^2));
dist = 4.5;
fov = 11;
fov_2 = fov/2;
p1xy = [3 3];
%%%
step = 22.5;
fun_bs_an = @(offset) mb.createAnnulusSegment(s1xy(1), s1xy(2), 0, dist, offset-fov_2, fov, num_pts)';
% p_bs = arrayfun(fun_bs_an, step:step:180-step, 'uniformoutput', false);
p_bs = arrayfun(fun_bs_an, s1rot+step, 'uniformoutput', false);

fun_ts_an = @(offset) mb.createAnnulusSegment(s2xy(1), s2xy(2), 0, dist, offset-fov_2, fov, num_pts)';
% step = 22.5;
% p_ts = arrayfun(fun_ts_an, step+180:step:360-step, 'uniformoutput', false);
p_ts = arrayfun(fun_ts_an, s2rot+step, 'uniformoutput', false);

fun_ls_an = @(offset) mb.createAnnulusSegment(s3xy(1), s3xy(2), 0, dist, offset-fov_2, fov, num_pts)';
% step = 22.5;
% p_ts = arrayfun(fun_ts_an, step+180:step:360-step, 'uniformoutput', false);
p_ls = arrayfun(fun_ls_an, s3rot, 'uniformoutput', false);

fun_trans = @(p) cellfun(@(x) x', p, 'uniformoutput', false);
b_ts = cellfun(@(x) x', p_ts, 'uniformoutput', false);
b_bs = cellfun(@(x) x', p_bs, 'uniformoutput', false);
b_ls = cellfun(@(x) x', p_ls, 'uniformoutput', false);
b_all = [b_ts, b_bs, b_ls];
combs = comb2unique(1:numel(b_all));
cuts = bpolyclip_batch(b_all, 1, combs, true);

cts = cuts(~cellfun(@isempty, cuts));
p_cuts = mb.boost2visilibity(cts);
% p_middle = p_cuts{15};

rect_bnd = rectToPolygon([1 1 4 4]);
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
xlim([0.5 5.5]);
ylim([0.5 5.5]);
% set(gca, 'YTick', 0:5);
set(gca, 'color', 'w');



text('position', s1xy+[-0.2 -0.2], 'string', '$S_1$', 'Horizontalalignment', 'center', 'Verticalalignment', 'middle')
text('position', s2xy+[-0.2 -0.2], 'string', '$S_2$', 'Horizontalalignment', 'center', 'Verticalalignment', 'middle')
text('position', s3xy+[-0.2 -0.2], 'string', '$S_3$', 'Horizontalalignment', 'center', 'Verticalalignment', 'middle')

% text('Interpreter', 'none', 'position', [1.5 4], 'string', 'd1');
% text('Interpreter', 'none', 'position', [3.8 4], 'string', 'd2')

% text('Interpreter', 'none', 'position', p1xy+[-0.1 -0.3], 'string', 'O')

fillPolygon(p_bnd, col(10,:));
drawPolygon(p_bnd, 'color', col(6,:));
drawPolygon(rect_bnd, 'color', col(1,:), 'LineWidth', 3);
fillPolygon(p_cuts, col(7,:));

% mb.numberRings(p_cuts);
% fillPolygon(p_middle, col(2,:));
% drawPolygon(rect_bnd, 'color', col(1,:));
x_coord = (1:5)';
y_coord = (1:5)';
all_coord = [x_coord, ones(size(x_coord)); ones(size(y_coord)) y_coord; x_coord, ones(size(x_coord))*5; ones(size(y_coord))*5 y_coord];

drawPoint(s1xy, 'marker', 'o','MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'markersize', 10);
drawPoint(s2xy, 'marker', 'o', 'MarkerEdgeColor', 'k','MarkerFaceColor', 'k', 'markersize', 10);
drawPoint(s3xy, 'marker', 'o', 'MarkerEdgeColor', 'k','MarkerFaceColor', 'k', 'markersize', 10);
drawPoint(all_coord, 'marker', 'o', 'MarkerEdgeColor', 'k','MarkerFaceColor', 'k', 'markersize', 10);

drawPoint(p1xy, 'marker', 'x','MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'markersize', 10, 'LineWidth', 3, 'color', col(2,:));
drawPoint([2 2], 'marker', 'x','MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'markersize', 10, 'LineWidth', 3, 'color', col(2,:));
drawPoint([4 2], 'marker', 'x','MarkerEdgeColor', 'k', 'MarkerFaceColor', 'k', 'markersize', 10, 'LineWidth', 3, 'color', col(2,:));

text('position', [1.9 1.5], 'string', '$C_{1,3}$');
text('position', [3.8 1.5], 'string', '$C_{2, 3}$');
text('position', [2.85 2.4], 'string', '$C_{1, 2}$');


%%%
p_ad = mb.createAnnulusSegment(5, 3, 0, dist, 175, fov, num_pts)';
p_ad2 = mb.createAnnulusSegment(2, 5, 0, dist, 265, fov, num_pts)';
p_ad3 = mb.createAnnulusSegment(3, 1, 0, dist, 40, fov, num_pts)';
p_ads = {p_ad, p_ad2, p_ad3};

text('position', [5 3]+[.3 0.2], 'string', '$S_4$', 'Horizontalalignment', 'center', 'Verticalalignment', 'middle')
text('position', [2 5]+[-0.2 .2], 'string', '$S_6$', 'Horizontalalignment', 'center', 'Verticalalignment', 'middle')
text('position', [3 1]+[-0.2 -0.2], 'string', '$S_5$', 'Horizontalalignment', 'center', 'Verticalalignment', 'middle')


% p_ad = mb.createAnnulusSegment(5, 3, 0, dist, 190, fov, num_pts)';
%%%
fun_trans = @(p) cellfun(@(x) x', p, 'uniformoutput', false);
b_ads = cellfun(@(x) x', p_ads, 'uniformoutput', false);
% b_bs = cellfun(@(x) x', p_bs, 'uniformoutput', false);
% b_ls = cellfun(@(x) x', p_ls, 'uniformoutput', false);
% b_all = [b_ts, b_bs, b_ls];
% combs = comb2unique(1:numel(b_all));
% cuts = bpolyclip_batch(b_all, 1, combs, true);

% cts = cuts(~cellfun(@isempty, cuts));
% p_cuts = mb.boost2visilibity(cts);
% p_middle = p_cuts{15};

rect_bnd = rectToPolygon([1 1 4 4]);
b_ads_bnd = bpolyclip_batch([{rect_bnd'}, b_ads], 1, [ones(numel(b_ads),1), (2:numel(b_ads)+1)'], true);
b_ads_bnd_fl = mb.flattenPolygon(b_ads_bnd);
p_ads_bnd = fun_trans(b_ads_bnd_fl);
drawPolygon(p_ads_bnd, 'k', 'linestyle', '--');
% lcon = [s1xy; p1xy; s2xy];
% plot(lcon(:,1),lcon(:,2), 'LineWidth', 2, 'color', col(2,:));

% ang1 = -pi + angle2Points(s1xy, p1xy);
% anginner = angle3Points(s1xy, p1xy, s2xy);

%
% seg_ang = circleArcToPolyline([p1xy, 0.5, rad2deg(ang1), rad2deg(anginner)], num_pts);
% hseg_ang = drawPolyline(seg_ang);
% set(hseg_ang, 'color', 'k')
%%
    filename = sprintf('MultiIntersections.tex');
    full_filename = sprintf('export/%s', filename);
    matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '7cm',...
        'width', '10cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    %     find_and_replace(full_filename, 'ylabel={\[\\#\]}', 'ylabel={[\\#SP]},\nevery axis y label/.style={at={(current axis.north west)},anchor=east}');
    %     find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');
    %     find_and_replace(full_filename,'bar\ shift=.\d.\d*cm,', '');
    %     find_and_replace(full_filename,'bar\ shift=\d.\d*cm,', '');
    %     find_and_replace(full_filename,'inner\ sep=0mm', 'inner sep=1pt');
    Figures.compilePdflatex(filename, false, false);
% Figures.makeFigure('MultiIntersections');
% matlab2tikz('fig/multi_intersections.tex');
