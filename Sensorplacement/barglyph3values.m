function [h0 h1out] = barglyph3values(xlist,ylist,height, width,graph_data, graph_data2, xrange, yrange, graph_data3, graph_data4)
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

data_max3 = max(graph_data3(:));
data_min3 = min(graph_data3(graph_data3>0));
data_range3 = data_max3-data_min3;

data3_scale = data_range/data_range3;

data_max4 = max(graph_data4(:));
data_min4 = min(graph_data4(graph_data4>0));
data_range4 = data_max4-data_min4;

data4_scale = data_range/data_range4;


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
    d3 = graph_data3(i, :);
    d4 = graph_data4(i, :);
    strlabel = arrayfun(@(x) strrep(sprintf('{\\small %d}', x), '{\small NaN}', ''), d, 'uniformoutput', false);
    h1= axes('position',[x y w h],... 
        'ycolor',[0 0 0], 'xcolor',[0 0 0],... 
        'ytick',[], 'Ticklength', [0 0],...
        'xlim', [0.4 numel(d)+0.6],...
        'ylim', [data_min data_max], ...
        'Box', 'on',...
        'XTick', 1:numel(d), 'XTickLabel', strlabel);
    hold on;
    %%%
    clne = linspace(0.4, 0.8, numel(d));
    cbar = [clne', clne', clne'];
    bar_width = 0.8 ;
    for idb = 1:numel(d)
        if  ~isnan(d(idb))
        bar(h1, idb, d(idb) , 'linestyle', 'none', 'facecolor', cbar(idb, :), 'BarWidth', bar_width );
        yvalue = 1.5*data_min+(d2(idb)-data_min2)*data2_scale*0.5;
        yvalue4 = data_min+((d4(idb)-data_min4)*data4_scale)*0.5;
        xvalues = [idb-bar_width/2 idb+bar_width/2];
%         id_clr_rev = numel(d)-idb+1;
        plot(h1, xvalues, [yvalue yvalue], 'HandleVisibility','off', 'linestyle', '-', 'linewidth', 1, 'color', 'k');
        plot(h1, xvalues, [yvalue4 yvalue4], 'HandleVisibility','off', 'linestyle', '-', 'linewidth', 1, 'color', 'k');
        plot(h1, idb, data_min+((d3(idb)-data_min3)*data3_scale)/2, 'marker', 'd', 'HandleVisibility','off', 'color', 'k');
%         plot(h1, idb, yvalue4, 'marker', '+', 'HandleVisibility','off', 'color', 'k');
        ht = text(idb, yvalue, sprintf('{\\tiny $%d$}', (d2(idb))), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom', 'color', 'k', 'interpreter', 'none');%, 'BackgroundColor', ones(1,3));
        ht4 = text(idb, yvalue4, sprintf('{\\tiny $%d$}', round((d4(idb)))), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top', 'color', 'k', 'interpreter', 'none');%, 'BackgroundColor', ones(1,3));
%         tydat = get(ht, 'Extent');
%         tydatmax = sum(tydat([2,4]));
%         if tydatmax > data_max
%             set(ht, 'VerticalAlignment', 'top');
%         end
        end
    end
    if i == 1
        h1out = h1;
    end
end

return;