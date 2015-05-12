function [h0 h1out] = barglyph2values(xlist,ylist,height, width,graph_data, graph_data2, xrange, yrange)
%%
canvas_range = [0.1 0.9];
canvas_length = diff(canvas_range);

xlength = diff(xrange);
ylength = diff(yrange);
h = height/(xlength);
w = width/(ylength);

data_max = max(graph_data(:));
data_min = min(graph_data(graph_data>0));
data_range = data_max-data_min;

data_max2 = max(graph_data2(:));
data_min2 = min(graph_data2(graph_data2>0));
data_range2 = data_max2-data_min2;

data2_scale = data_range/data_range2;
% data2_offset = data_min-data_min2;

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
%     delete(h1)
    d = graph_data(i, :);
    d2 = graph_data2(i, :);
    strlabel = arrayfun(@(x) strrep(num2str(x), 'NaN', ''), d, 'uniformoutput', false);
    h1= axes('position',[x y w h], 'ycolor',[0 0 0], 'xcolor',[0 0 0], 'ytick',[], 'Ticklength', [0 0],...
        'xlim', [0.4 numel(d)+0.6],...
        'ylim', [data_min data_max], ...
        'Box', 'on',...
        'XTick', 1:numel(d), 'XTickLabel', strlabel);
    hold on;
    
    clne = linspace(0.4, 0.8, numel(d));
    cbar = [clne', clne', clne'];
    bar_width = 0.8 ;
    for idb = 1:numel(d)
        bar(h1, idb, d(idb) , 'linestyle', 'none', 'facecolor', cbar(idb, :), 'BarWidth', bar_width );
        yvalue = data_min+(d2(idb)-data_min2)*data2_scale;
        xvalues = [idb-bar_width/2 idb+bar_width/2];
%         id_clr_rev = numel(d)-idb+1;
        plot(h1, xvalues, [yvalue yvalue], 'HandleVisibility','off', 'linestyle', '-', 'linewidth', 1, 'color', 'k');      
        ht = text(idb, yvalue, sprintf('{\\bf $%d$}', (d2(idb))), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'color', 'k', 'interpreter', 'none');
        tydat = get(ht, 'Extent');
        tydatmax = sum(tydat([2,4]));
        if tydatmax > data_max
            set(ht, 'VerticalAlignment', 'top');
        end
    end
    if i == 1
        h1out = h1;
    end
end

return;