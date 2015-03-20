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
        mean_wpn_qualities = zeros(2601,1);
        sp_selected_mat = zeros(2601,1);
        opt = opts.(opt_name);
        flt_eval = ~cellfun(@isempty, opt);
        
        num_sp= cellfun(@(x) x.num_sp, opt(flt_eval));
        num_wpn = cellfun(@(x) x.num_wpn, opt(flt_eval));
        
        sp_selected = cellfun(@(x) numel(x.sensors_selected), opt(flt_eval));
        wpn_qualities = cellfun(@(x) x.quality.sum_max/x.all_wpn, opt(flt_eval));
    
        ids = sub2ind([51, 51], num_sp/10+1, num_wpn/10+1);
        mean_wpn_qualities(ids) = wpn_qualities;
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

xlist = X(ind);
ylist = Y(ind);
height = 20;
width = 30;
xrange = [-30 540];
yrange = [-30 530];

all_x = unique(xlist);
all_y = unique(ylist);

%%
close all;
% h0 = barglyph(xlist, ylist, height, width, all_mean_wpn_qualities(ind, 1:5), xrange, yrange);
% figure;
% h0 = barglyph(xlist, ylist, height, width, all_mean_wpn_qualities(ind, [1:3, 5]), xrange, yrange);

all_mean_wpn_qualities_rounded = round(all_mean_wpn_qualities*100);

figure;
h0 = barglyph(xlist, ylist, height, width, all_mean_wpn_qualities_rounded(ind, [1:3, 5]), xrange, yrange);

figure;
h0 = barglyph(xlist, ylist, height, width, all_mean_wpn_qualities_rounded(ind, [4,8:10]), xrange, yrange);

figure;
h0 = barglyph(xlist, ylist, height, width, all_num_sp_selected(ind, [1:3, 5]), xrange, yrange);

figure;
h0 = barglyph(xlist, ylist, height, width, all_num_sp_selected(ind, [4,8:10]), xrange, yrange);

%%
% inputs = arrayfun(@(wpn, sp) Experiments.Diss.small_flat(wpn, sp), all_x, all_y,'uniformoutput', false);
% real_num_sp = cellfun(@(x) x.discretization.num_sensors, inputs);
% real_num_wpn = cellfun(@(x) x.discretization.num_positions, inputs);


strlabelsx = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_x, real_num_sp, 'uniformoutput', false);
strlabelsy = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_y, real_num_wpn, 'uniformoutput', false);
set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
xlabel(h0,'\#$WPN$', 'interpreter', 'none');
ylabel(h0, '\#$SP$', 'interpreter', 'none');






%%
% matlab2tikz('export\SmallFlatWpnCoverageNumSp.tikz', 'parseStrings', false,...
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'extraAxisOptions',{'y post scale=1'});

matlab2tikz('export\SmallFlatWpnCoverageNumSp.tikz', 'parseStrings', false,...
    'tikzFileComment', '% -*- root: SmallFlatWpnCoverageNumSp.tex -*-',... 
    'extraAxisOptions',{'y post scale=1',...
    'every x tick label/.append style={tickwidth=0cm,major tick length=0cm}'});
%     'standalone', true);
%     'every outer x axis line/.append style={black}'});


find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar width=0.025453in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=-0.063633in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=-0.031817in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=0.031817in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=0.063633in,', '');
% find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','area legend,', 'major x tick style = transparent,');

Figures.writeTexFile('SmallFlatWpnCoverageNumSp.tikz', 'export\');


%%
