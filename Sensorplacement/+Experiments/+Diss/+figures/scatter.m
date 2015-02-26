function scatter( opts )
%SCATTER Summary of this function goes here
%   Detailed explanation goes here

opt_names = {'gco', 'gcss', 'gsss', 'mspqm', 'stcm', 'cmqm_nonlin_it', 'cmqm_cmaes_it'};

%%
gray_colorline = linspace(0,0.8,55)';
gray_colormap = repmat(gray_colorline, 1, 3);


%%
for idn = 1:numel(opt_names)
    %%
    opt_name = opt_names{idn};
    
    opt = opts.(opt_name);
    flt_eval = ~cellfun(@isempty, opt);
    
    %%
    num_sp = cellfun(@(x) x.num_sp, opt(flt_eval));
    num_wpn = cellfun(@(x) x.num_wpn, opt(flt_eval));
%     [X Y] = meshgrid(num_sp, num_wpn);
    
    %%
    num_sp_selected = cellfun(@(x) numel(x.sensors_selected), opt(flt_eval));
%     mean_sp_qualities = cellfun(@(x) mean(cellfun(@(x) max(x), x.quality.wss.val)), opts.(opt_name)); %, 'uniformoutput', false);
    sum_max_qualities = cellfun(@(x) x.quality.sum_max, opt(flt_eval));  
    

    %%
    figure;
    set(gcf, 'color', [1 1 1]);
    axes('position', [0.1 0.1 0.6 0.8]);
    sum_max_qualities_scaled = sum_max_qualities./max(sum_max_qualities);
    scale = 50;
    scatter(num_sp(:), num_wpn(:), sum_max_qualities_scaled(:)*scale, num_sp_selected(:), 'fill');
    
    colormap(gray_colormap);
    title(opt_name, 'interpreter', 'none');
    colorbar;
    xlim([0 500]);
    ylim([0 500]);

    axes('position', [0.7 0.1 0.1 0.8]);
    colormap(gray_colormap);
    sizebar = linspace( min(sum_max_qualities_scaled), max(sum_max_qualities_scaled) , 11 )*scale;
    spnumbar = linspace(min(num_sp_selected), max(num_sp_selected), 11);
    scatter(zeros(11,1), (0:50:500)', sizebar(:), spnumbar(:), 'fill');
    %% ADD TEXT
    axis off;
end


