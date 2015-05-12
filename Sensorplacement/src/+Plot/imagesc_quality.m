function h0 = imagesc_quality(xlist,ylist,graph_data, xrange, yrange)
%%

data_max = max(graph_data(:));
data_min = min(graph_data(graph_data>0));

% gray_colorline = linspace(0,0.8,100)';
% gray_colormap = repmat(gray_colorline, 1, 3);

%%
all_x = unique(xlist);
all_y = unique(ylist);
gray_colormap = repmat(linspace(data_min, data_max, 1000)', 1, 3);


for i = 1:size(graph_data,1)
    
figure;
h0 = axes('xlim',xrange,'ylim',yrange, 'ytick', all_y, 'xtick', all_x, 'Color', [1 1 1]);
colormap(gray_colormap);

image(reshape(graph_data(:, 1), numel(all_x), numel(all_y)))

end
%%
% for i = 1:size(graph_data,1)
%     
%     x = (xlist(i)-xrange(1))/(xlength)*canvas_length+canvas_range(1)-w/2;
%     y = (ylist(i)-yrange(1))/(ylength)*canvas_length+canvas_range(1)-h/2;
%         
%     %%
%     d = graph_data(i, :);
%     strlabel = arrayfun(@(x) num2str(x), d, 'uniformoutput', false);
%     h1= axes('position',[x y w h], 'ycolor',[0 0 0], 'xcolor',[0 0 0], 'ytick',[], 'Ticklength', [0 0],...
%         'xlim', [0.5 numel(d)+0.5], 'ylim', [data_min data_max], 'Box', 'on',...
%         'XTick', 1:numel(d), 'XTickLabel', strlabel);
%     hold on;
%     
%     clne = linspace(0, 0.8, numel(d));
%     cbar = [clne', clne', clne'];
%     for idb = 1:numel(d)
%         bar(h1, idb, d(idb) , 'linestyle', 'none', 'facecolor', cbar(idb, :), 'BarWidth', 0.8 );
%     end
% end

return;
