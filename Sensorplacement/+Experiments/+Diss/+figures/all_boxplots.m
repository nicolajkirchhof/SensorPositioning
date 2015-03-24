
%%
clearvars -except all_eval;
% clearvars -except small_flat conference_room large_flat office_floor
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
%%
figure;
for ideval = 1:numel(eval_names)
    % ideval = 4;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    
    %%
    % opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it', 'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd', 'cmcqm_cmaes_it', 'cmcqm_nonlin_it'};
    %                  1                 2            3      4       5       6        7        8         9            10           11                 12
    subplot(2, 2, ideval);
    boxplot(opts.all_mean_wpn_qualities, 'labels', opts.opt_names, 'colors', [0.4 0.4 0.4], 'symbol', 'k+');
    h = findobj(gcf,'Tag','Outliers');
    % make median lines black and big
    set(findobj(gcf,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);
    
    % make outlier dots gray and big
    set(findobj(gcf,'Tag','Outliers'),'MarkerEdgeColor',[0.6 0.6 0.6]);
    
    title(sprintf('%s qualities', eval_name), 'interpreter', 'none');
    
    
end


%%

figure;
for ideval = 1:numel(eval_names)
        % ideval = 4;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    
    subplot(2, 4, ideval*2);
    boxplot(opts.all_num_sp_selected, 'labels', opts.opt_names, 'colors', [0.4 0.4 0.4], 'symbol', 'k+');
    h = findobj(gcf,'Tag','Outliers');
    % make median lines black and big
    set(findobj(gcf,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);
    
    % make outlier dots gray and big
    set(findobj(gcf,'Tag','Outliers'),'MarkerEdgeColor',[0.6 0.6 0.6]);
    
    title(sprintf('%s sensors', eval_name), 'interpreter', 'none');
end