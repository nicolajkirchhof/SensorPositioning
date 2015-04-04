%%
close all;
col = repmat((0:10)', 1, 3)*0.1;
% xlim([800 6000]);
% ylim([800 6000]);

txt_props = {'horizontalalignment', 'center', 'verticalalignment', 'middle'};

fun_trans = @(p) cellfun(@(x) x', p, 'uniformoutput', false);
rect_env = int64(rectToPolygon([1 1 10 4]*1000));
rect_env = [rect_env(1,:); [5000 1500]; rect_env(2:end, :)]; 
obst_env = int64(flipud(rectToPolygon([5 3 2.5 1]*1000)));
p_comb_env = {rect_env, obst_env};

b_comb_env = bpolyclip(fun_trans(p_comb_env(1)), fun_trans(p_comb_env(2)), 0, true);

vpl = visilibity(int64([1 6;1 1]*1000), b_comb_env{1}, 10, 10); 

cla, hold on, axis equal, axis off
set(gca, 'color', 'w');

num_pts = 1000;
fov = 45;
fov_2 = fov/2;

drawPolygon(vpl{1}','color', col(7,:), 'linestyle', '-', 'linewidth', 6);
drawPolygon(rect_env, 'color', 'k', 'linewidth', 2);
drawPolygon(obst_env, 'color', 'k', 'linewidth', 2);
fillPolygon(obst_env, 0.2*ones(1,3));

text(1000, 1000, '$P_1$', txt_props{:}, 'horizontalalignment', 'center', 'verticalalignment', 'top');
% text(2250, 2000, '$\Lambda_1$', txt_props{:});

drawPoint([1000 1000], 'marker', 'o','MarkerEdgeColor', col(2,:), 'markersize', 8, 'linewidth', 2);
% text(6050, 800, '$S_2$', txt_props{:});
% drawPoint([6000 1000], 'marker', 'o','MarkerEdgeColor', col(2,:), 'MarkerFaceColor', 'k', 'markersize', 6);

% Figures.makeFigure('VfovVisible');
filename = 'VfovVisibilityPolygon.tex';
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '5cm',...
    'width', '10cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);

    Figures.compilePdflatex(filename, true, true);
% Figures.compilePdflatex(filename, false);
