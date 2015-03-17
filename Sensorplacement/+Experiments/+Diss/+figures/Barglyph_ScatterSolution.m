%%
opts = small_flat;
opt_names = fieldnames(opts);
gray_colorline = linspace(0,0.8,50)';
gray_colormap = repmat(gray_colorline, 1, 3);
set(gcf, 'color', [1 1 1]);
%%
all_num_sp_selected= zeros(2601, 10); %cell(numel(opt_names), 1);
all_mean_wpn_qualities = zeros(2601, 10); %zeros(51, 51); %cell(numel(opt_names), 1);
all_sp_wpn = zeros(51, 51);

% all_num_sp = {}; %cell(numel(opt_names), 1);
% all_num_wpn = {}; %cell(numel(opt_names), 1);/
%%%
cnt = 1;
for idn = 1:numel(opt_names)
    opt_name = opt_names{idn};
    if ~any(strcmp(opt_name, {'cmcqm_cmaes_it', 'cmcqm_nonlin_it'}))
        %%
        opt = opts.(opt_name);
        flt_eval = ~cellfun(@isempty, opt);
        
        num_sp= cellfun(@(x) x.num_sp, opt(flt_eval));
        num_wpn = cellfun(@(x) x.num_wpn, opt(flt_eval));
        
        sp_selected = cellfun(@(x) numel(x.sensors_selected), opt(flt_eval));
        wpn_qualities = cellfun(@(x) x.quality.sum_max/x.all_wpn, opt(flt_eval));
    
        ids = sub2ind([51, 51], num_sp/10+1, num_wpn/10+1);
        mean_wpn_qualities(ids) = sp_selected;
        sp_selected_mat(ids) = sp_selected;
        all_mean_wpn_qualities(:, cnt)  = mean_wpn_qualities(:);
        all_num_sp_selected(:, cnt) = sp_selected_mat(:);
        cnt = cnt+1;
    end
end


%%
[X, Y] = meshgrid(0:10:500, 0:10:500);
range = 1:5:51;
[idx, idy] = meshgrid(range, range);
ind = sub2ind([51 51], idx(:), idy(:));
%%
% x = X(range, range);
% y = Y(range, range);

xlist = X(ind);
ylist = Y(ind);
hlist = 10*ones(size(xlist));
wlist = 20*ones(size(xlist));
xrange = [-30 530];
yrange = [-30 530];

% graph_data = cellfun(@(x) x(range, range), all_mean_wpn_qualities, 'uniformoutput', false);

barglyph(xlist, ylist, hlist, wlist, all_mean_wpn_qualities(ind, 1:5), xrange, yrange);
legend(opt_names{1:5});

%%
figure;
glyphplot([v1(:), v2(:), v3(:)], 'centers',[x(:), y(:)], 'radius', 20);