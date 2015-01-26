function contours = contour()

c = load('tmp\contours\contours.mat');
contours = c.contours;

return;
%%
% import Figures.*;
clear variables;
x1 = 0;
y1 = 0;
y2 = 0;
dmax = 10000;
distances = 100:100:13100;%20000;
% Z = cell(numel(distances), 1);
b_chulls = cell(numel(distances), 1);
loop_display(numel(distances), 5);
%%%
for id_di = 1:numel(distances)
    x2 = distances(id_di);
    %%%
    x = -5000:10:x2+5000;
    y = 0:10:10000;
    [X, Y] = meshgrid(x, y);

    %%%
    a_sq = (X - x1).^2 + (Y - y1).^2;
    a = sqrt(a_sq);
    b_sq = (X - x2).^2 + (Y - y2).^2;
    b = sqrt(b_sq);
    c_sq = (x1 - x2).^2 + (y1 - y2).^2;
    c = sqrt(c_sq);
    Z = 1 - (2 * a_sq .* b_sq ) ./ ( dmax^2 * sqrt( (b-a+c) .* (a-b+c) .* (a+b-c) .* (a+b+c) ) );
    Z = real(Z);
    Z(1001, :) = 0;
    Z(Z<0) = 0;
    
    a_flt = dmax^2 < a_sq;
    b_flt = dmax^2 < b_sq;
    Z(a_flt|b_flt) = 0;
    %%%
    Z_flt = Z > 0.45;
    [x_ch, y_ch] = find(Z_flt);
    id_chull = convhull(y_ch, x_ch);
    %%%
    p_chull = {[y_ch(id_chull)-500, x_ch(id_chull)]*10, [y_ch(id_chull)-500, -x_ch(id_chull)]*10  };
    b_chull = mb.visilibity2boost(p_chull);
    nums_before = cellfun(@(x) size(x, 2), b_chull);
    %%
    b_chull_merged = mb.mergePoints(b_chull, 10);
    nums_after = cellfun(@(x) size(x, 2), b_chull_merged);
    fprintf(1, '%d -> %d\n', nums_before(1), nums_after(1));
    %%
%     mb.drawPolygon(b_chull);
%     mb.drawPolygon(b_chull_merged, 'color', 'g');
    b_chull_correct1 = bpolyclip(b_chull_merged{1}, b_chull_merged{1}, 1, 10, 1);
    b_chull_correct2 = bpolyclip(b_chull_merged{2}, b_chull_merged{2}, 1, 10, 1);
    b_chull_merged = [b_chull_correct1{1}, b_chull_correct2{1}];
    %%
    b_chulls{id_di} = b_chull_merged;
    
    loop_display(id_di);
end
%%
contours.b_chulls = b_chulls;
contours.distances = distances;
save('tmp\contours\contours.mat', 'contours');
