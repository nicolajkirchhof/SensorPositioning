function h0 = barglyph(xlist,ylist,height, width,graph_data, xrange, yrange)
%%
canvas_range = [0.1 0.9];
canvas_length = diff(canvas_range);

xlength = diff(xrange);
ylength = diff(yrange);
h = height/(xlength);
w = width/(ylength);

data_max = max(graph_data(:));
data_min = min(graph_data(graph_data>0));

%%
clf;
all_x = unique(xlist);
all_y = unique(ylist);

h0 = axes('position',[canvas_range(1), canvas_range(1), canvas_length, canvas_length], ...
    'xlim',xrange,'ylim',yrange, 'ytick', all_y, 'xtick', all_x, 'Color', [1 1 1]);

%%
for i = 1:size(graph_data,1)
    
    x = (xlist(i)-xrange(1))/(xlength)*canvas_length+canvas_range(1)-w/2;
    y = (ylist(i)-yrange(1))/(ylength)*canvas_length+canvas_range(1)-h/2;
        
    %%
    d = graph_data(i, :);
    strlabel = arrayfun(@(x) num2str(x), d, 'uniformoutput', false);
    h1= axes('position',[x y w h], 'ycolor',[0 0 0], 'xcolor',[0 0 0], 'ytick',[], 'Ticklength', [0 0],...
        'xlim', [0.5 numel(d)+0.5], 'ylim', [data_min data_max], 'Box', 'on',...
        'XTick', 1:numel(d), 'XTickLabel', strlabel);
    hold on;
    
    clne = linspace(0, 0.8, numel(d));
    cbar = [clne', clne', clne'];
    for idb = 1:numel(d)
        bar(h1, idb, d(idb) , 'linestyle', 'none', 'facecolor', cbar(idb, :), 'BarWidth', 0.8 );
    end
end

return;
