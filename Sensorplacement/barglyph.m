function barglyph(xlist,ylist,hlist, wlist,graph_data, xrange, yrange)
%%
% range = 1:5:size(X,1);
% x = X(range, range);
% y = Y(range, range);
% v1 = num_sp_selected_gco(range, range);
% v2 = num_sp_selected_gcss(range, range);
% v3 = num_sp_selected_gsss(range, range);
% 
% xlist = x(:);
% ylist = y(:);
% slist = 20*ones(size(xlist));
% xrange = [-10 510];
% yrange = [-10 510];
% 
% graph_data = [v1(:), v1(:), v3(:)];

canvas_range = [0.1 0.9];
canvas_length = diff(canvas_range);

xlength = diff(xrange);
ylength = diff(yrange);

data_max = max(graph_data(:));

%%
clf;
h0 = axes('position',[canvas_range(1), canvas_range(1), canvas_length, canvas_length], ...
    'xlim',xrange,'ylim',yrange);
for i = 1:size(graph_data,1)
h = hlist(i)/(xlength);
w = wlist(i)/(ylength);
x = (xlist(i)-xrange(1))/(xlength)*canvas_length+canvas_range(1)-h/2;
y = (ylist(i)-yrange(1))/(ylength)*canvas_length+canvas_range(1)-w/2;

h1= axes('position',[x y w h], 'Visible', 'off');
hold on;
d = graph_data(i, :);
% d = d-min(d);
clne = linspace(0, 0.8, numel(d));
cbar = [clne', clne', clne'];
for idb = 1:numel(d)
    bar(h1, idb, d(idb) , 'linestyle', 'none', 'facecolor', cbar(idb, :) );
end
axis off
xlim([0.5 numel(d)+0.5]);
ylim([0 data_max]);
end

xlim(h0, xrange);
ylim(h0, yrange);
return;
%%