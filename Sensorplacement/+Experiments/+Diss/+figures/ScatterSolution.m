names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
idn = 1;
name = names{idn};

load(sprintf('tmp/%s/gco.mat', name));
load(sprintf('tmp/%s/gcss.mat', name));
load(sprintf('tmp/%s/gsss.mat', name));
load(sprintf('tmp/%s/mspqm.mat', name));
%%
opt_names = {'gco', 'gcss', 'gsss', 'mspqm'};
opt = [];
for idn = 1:numel(opt_names)
    opt_name = opt_names{idn};
    opt.(opt_name) = eval([opt_name ';']);
end

%%
gray_colorline = linspace(0,0.8,50)';
gray_colormap = repmat(gray_colorline, 1, 3);
set(gcf, 'color', [1 1 1]);
%%
for idn = 1:numel(opt_names)
    %%
    opt_name = opt_names{idn};
    figure;
    num_sp_selected = cellfun(@(x) numel(x.sensors_selected), opt.(opt_name));
    mean_sp_qualities = cellfun(@(x) mean(cellfun(@(x) max(x), x.quality.wss.val)), opt.(opt_name)); %, 'uniformoutput', false);
    
    num_sp = cellfun(@(x) x.num_sp, opt.(opt_name)(:,1));
    num_wpn = cellfun(@(x) x.num_wpn, opt.(opt_name)(1,:));
    [X Y] = meshgrid(num_sp, num_wpn);
    %%
    scatter(X(:), Y(:), mean_sp_qualities(:)*50, num_sp_selected(:), 'fill');
    
    colormap(gray_colormap);
    title(name);
    colorbar;
end

%%
range = 1:5:size(X,1);
x = X(range, range);
y = Y(range, range);
v1 = num_sp_selected_gco(range, range);
v2 = num_sp_selected_gcss(range, range);
v3 = num_sp_selected_gsss(range, range);

xlist = x(:);
ylist = y(:);
slist = 20*ones(size(xlist));
xrange = [-10 510];
yrange = [-10 510];

graph_data = [v1(:), v1(:), v3(:)];

barglyph(xlist, ylist, slist, graph_data, xrange, yrange);

%%
figure;
glyphplot([v1(:), v2(:), v3(:)], 'centers',[x(:), y(:)], 'radius', 20);