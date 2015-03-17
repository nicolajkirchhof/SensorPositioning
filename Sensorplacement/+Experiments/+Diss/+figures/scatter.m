function scatter( opts , max_sp)
%SCATTER Summary of this function goes here
%   Detailed explanation goes here
opts = small_flat;
max_sp = 100;
% opt_names = {'gco', 'gcss', 'gsss', 'mspqm', 'stcm', 'cmqm_nonlin_it', 'cmqm_cmaes_it'};

%%
% num_colors = 55;
min_sp_selected = inf;
max_sp_selected = -inf;
min_quality = inf;
max_quality = -inf;
for idn = 1:numel(opt_names)
    opt_name = opt_names{idn};
    if ~any(strcmp(opt_name, {'cmcqm_cmaes_it', 'cmcqm_nonlin_it'}))
        
        opt = opts.(opt_name);
        flt_eval = ~cellfun(@isempty, opt);
        num_sp_selected = cellfun(@(x) numel(x.sensors_selected), opt(flt_eval));
        if max(num_sp_selected) > max_sp_selected
            max_sp_selected = max(num_sp_selected);
        end
        if min(num_sp_selected) < min_sp_selected
            min_sp_selected = min(num_sp_selected);
        end
        mean_qualities = cellfun(@(x) x.quality.sum_max/x.all_wpn, opt(flt_eval));
        if max(mean_qualities) > max_quality
            max_quality = max(mean_qualities);
        end
        if min(mean_qualities) < min_quality
            min_quality = min(mean_qualities);
        end
        
    end
end


opt_names = fieldnames(opts);
gray_colorline = linspace(0,0.8,max_sp_selected)';
gray_colormap = repmat(gray_colorline, 1, 3);

%%
for idn = 1:numel(opt_names)
    
    %%
    opt_name = opt_names{idn};
    if ~any(strcmp(opt_name, {'cmcqm_cmaes_it', 'cmcqm_nonlin_it'}))
        
        opt = opts.(opt_name);
        flt_eval = ~cellfun(@isempty, opt);
        
        %%
        num_sp = cellfun(@(x) x.num_sp, opt(flt_eval));
        num_wpn = cellfun(@(x) x.num_wpn, opt(flt_eval));
        
        num_sp_selected = cellfun(@(x) numel(x.sensors_selected), opt(flt_eval));
        mean_qualities = cellfun(@(x) x.quality.sum_max/x.all_wpn, opt(flt_eval));
        
        %%%
        figure;
        set(gcf, 'color', [1 1 1]);
        axes('position', [0.1 0.1 0.6 0.8]);
        %     sum_max_qualities_scaled = sum_max_qualities./max(sum_max_qualities);
        scale = 50;
        colors_sp = gray_colormap(num_sp_selected-min_sp_selected+1, :);
        scatter(num_sp(:), num_wpn(:), mean_qualities(:).^2*scale, colors_sp, 'fill');
        
        colormap(gray_colormap);
        
        title(opt_name, 'interpreter', 'none');
        colorbar;
        xlim([0 500]);
        ylim([0 500]);
        colorbar 'off'
        
        axes('position', [0.7 0.1 0.1 0.8]);
        colormap(gray_colormap);
        sizebar = linspace( min(mean_qualities), max(mean_qualities) , 11 )*scale;
        spnumbar = linspace(min_sp_selected, max_sp_selected, 11);
        scatter(zeros(11,1), (0:50:500)', sizebar(:), spnumbar(:), 'fill');
        axis off;
        %% ADD TEXT
        pos_y = 0:50:500;
        for idt = 1:numel(pos_y)
            y = pos_y(idt);
            text(0.5, y, sprintf('%g', sizebar(idt)/scale));
            text(-0.5, y, sprintf('%d', round(spnumbar(idt))));
        end
    end
end


