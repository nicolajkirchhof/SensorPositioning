opt_names = {'gco', 'gcss', 'gsss', 'mspqm', 'stcm', 'cmqm_nonlin_it', 'cmqm_cmaes_it'};
opts = small_flat;
%%
opt_name = 'cmqm_nonlin_it';
opt = opts.(opt_name);
for ido = 1:numel(opt)
   if ~isempty(opt{ido}) 
       opt{ido}.sensors_selected = opt{ido}.sol.sensors_selected;
       opt{ido}.quality.sum_max = -opt{ido}.solutions{end-1}.fmin;
   end
end

opts.(opt_name)= opt;
%%
opt_name = 'cmqm_cmaes_it';
opt = opts.(opt_name);
for ido = 1:numel(opt)
   if ~isempty(opt{ido}) 
       opt{ido}.sensors_selected = opt{ido}.sol.sensors_selected;
       opt{ido}.quality.sum_max = -opt{ido}.solutions{end-1}.fmin;
   end
end

opts.(opt_name)= opt;

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
    mean_sp_qualities = cellfun(@(x) mean(cellfun(@(x) max(x), x.quality.wss.val)), opts.(opt_name)); %, 'uniformoutput', false);
    

    %% 
    % TODO: first put all plots in one figure and then 
    % make a separate plot for colorbar and size explation
    figure;
    set(gcf, 'color', [1 1 1]);
    scatter(X(:), Y(:), mean_sp_qualities(:)*50, num_sp_selected(:), 'fill');
    
    colormap(gray_colormap);
    title(name);
    colorbar;
end