function barglyph(xlist,ylist,slist,graph_data, xrange, yrange)
% A Bubble Plot, Pie Chart Combination
% bubblepie(xlist,ylist,slist,graph_data,graph_labels,graph_legend,xlab,ylab,lab)
% 
% Creates a plot with pie charts at (xlist, ylist) using graph_data, having
% size of the pie scaled by slist.  Graph_labels contains a title for each
% pie chart, Graph_legend indicates the contents of graph_data, and lab is a
% binary value indicating whether pie chart labels are displayed.
% 
% Example:
% x = -pi:1:pi;
% x = x';
% y = sin(x);
% s = 1.1+cos(x);
% graph_labels = mat2cell(x,ones(1,length(x)),1);
% graph_data = 10*rand(length(x),3);
% graph_legend = {'one','two','three'};
% xlab = 'radians';
% ylab = 'sin(x)';
% lab = 1;
% 
% bubblepie(x,y,s,graph_data,graph_labels,graph_legend,xlab,ylab,lab)
% 
% title('BubblePie Plot')
% 
%   Abraham Anderson
%   July 30, 2007
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

% graph_max_size = 0.25;
% graph_min_size = 0.05;
% graph_range = graph_max_size-graph_min_size;

% canvas_max = 0.9;
% canvas_min = 0.1;
canvas_range = [0.1 0.9];
canvas_length = diff(canvas_range);

% maxx = max(xlist);
% maxy = max(ylist);
% minx = min(xlist);
% miny = min(ylist);
% maxs = max(slist);
xlength = diff(xrange);
ylength = diff(yrange);

%%
% figure
clf;
h0 = axes('position',[canvas_range(1), canvas_range(1), canvas_length, canvas_length], ...
    'xlim',xrange,'ylim',yrange);
% set(get(gca,'XLabel'),'String',xlab)
% set(get(gca,'YLabel'),'String',ylab)
%%%
for i = 1:size(graph_data,1)
%%
% s = slist(i)/maxs*graph_range+graph_min_size;
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



% set(gcf,'Currentaxes',h0)

return;
%%


text(0.1*maxx+minx,maxy-0.1*maxy,{'PieChart Groups (CCW):' graph_legend{:}},'verticalalignment','top');
if lab
    for i = 1:size(graph_data,1)
        s = slist(i)/maxs*graph_range+graph_min_size;
        x = (xlist(i)-minx)/(maxx-minx)*canvas_range+canvas_min-s/2;
        y = (ylist(i)-miny)/(maxy-miny)*canvas_range+canvas_min-s/2;
        d = graph_data(i,:);
        if sum(d)==0
            continue
        end
        d(d==0) = 0.1;
        axes('position',[x y s s])
        pie(d)
        title(graph_labels{i})
    end
else
    for i = 1:size(graph_data,1)
        s = slist(i)/maxs*graph_range+graph_min_size;
        x = (xlist(i)-minx)/(maxx-minx)*canvas_range+canvas_min-s/2;
        y = (ylist(i)-miny)/(maxy-miny)*canvas_range+canvas_min-s/2;
        d = graph_data(i,:);
        if sum(d)==0
            continue
        end
        d(d==0) = 0.1;
        axes('position',[x y s s])
        pie(d,{'' '' '' ''})
        title(graph_labels{i})
    end
end

set(gcf,'Currentaxes',h0)