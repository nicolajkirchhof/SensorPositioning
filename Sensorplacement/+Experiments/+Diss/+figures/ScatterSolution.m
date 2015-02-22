load tmp\conference_room\gco.mat;
load tmp\conference_room\gcss.mat
load tmp\conference_room\gsss.mat
%%
opt_names = {'gco', 'gcss', 'gsss'};
opt = [];
for idn = 1:numel(opt_names)
    name = opt_names{idn};
    opt.(name) = eval([name ';']);
end

%%
opt_names = {'gco', 'gcss', 'gsss'};

for idn = 1:numel(opt_names)
    name = opt_names{idn};
    figure;
    num_sp_selected = cellfun(@(x) numel(x.sensors_selected), opt.(name));
    
    num_sp = 0:10:500;
    num_wpn = 0:10:500;
    [X Y] = meshgrid(num_sp, num_wpn);
    
    scatter(X(:), Y(:), num_sp_selected(:)*10, num_sp_selected(:), 'fill');
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