function h0 = EvnironmentGlyph(xlist, ylist,height, width,solutions, xrange, yrange)
%%
canvas_range = [0.1 0.9];
canvas_length = diff(canvas_range);

xlength = diff(xrange);
ylength = diff(yrange);
h = height/(xlength);
w = width/(ylength);

%%
clf;
all_x = unique(xlist);
all_y = unique(ylist);

h0 = axes('position',[canvas_range(1), canvas_range(1), canvas_length, canvas_length], ...
    'xlim',xrange,'ylim',yrange, 'ytick', all_y, 'xtick', all_x, 'Color', [1 1 1]);

%%
for i = 1:size(solutions,1)
    
    x = (xlist(i)-xrange(1))/(xlength)*canvas_length+canvas_range(1)-w/2;
    y = (ylist(i)-yrange(1))/(ylength)*canvas_length+canvas_range(1)-h/2;
    
    %%
%     delete(h1)
   strlabel = arrayfun(@(x) strrep(sprintf('{\\footnotesize %d}', x), '{\footnotesize NaN}', ''), d, 'uniformoutput', false);
   axes('position',[x y w h],... 
        'ycolor',[0 0 0], 'xcolor',[0 0 0],... 
        'ytick',[], 'Ticklength', [0 0],...
        'xlim', [0.4 numel(d)+0.6],...
        'ylim', [data_min data_max], ...
        'Box', 'on',...
        'XTick', 1:numel(d), 'XTickLabel', strlabel);
    hold on;
    
end

return;