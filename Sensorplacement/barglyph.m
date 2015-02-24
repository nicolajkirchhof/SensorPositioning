function barglyph(xlist,ylist,slist,graph_data, xrange, yrange)
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

%%
clf;
h0 = axes('position',[canvas_range(1), canvas_range(1), canvas_length, canvas_length], ...
    'xlim',xrange,'ylim',yrange);
for i = 1:size(graph_data,1)
s = slist(i)/(xlength);
x = (xlist(i)-xrange(1))/(xlength)*canvas_length+canvas_range(1)-s/2;
y = (ylist(i)-yrange(1))/(ylength)*canvas_length+canvas_range(1)-s/2;

h1= axes('position',[x y s s], 'Visible', 'off');
hold on;
d = graph_data(i, :);
% d = d-min(d);
for idb = 1:numel(d)
    bar(h1, idb, d(idb), 'linestyle', 'none', 'facecolor', [0 0 0]+(1.5*idb/10) );
end
axis off
end

return;
%%