%% Draw All evaluation Properties
%%
clearvars -except all_eval;
% clearvars -except small_flat conference_room large_flat office_floor
%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
outdir = '..\..\Dissertation\thesis\figures\';

for ideval = 1:numel(eval_names)
    %%
    %     ideval = 1;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    %%
    % Preevaluation of all data
    % valid_flt = all_num_sp_selected >0;
    %'medianstyle', 'target',  'boxstyle', 'filled'
    figure, boxplot(opts.all_mean_wpn_qualities, 'labels', opts.opt_names, 'colors', [0.4 0.4 0.4], 'symbol', 'k+');
    h = findobj(gcf,'Tag','Outliers');
    % make median lines black and big
    set(findobj(gcf,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);
    
    % make outlier dots gray and big
    set(findobj(gcf,'Tag','Outliers'),'MarkerEdgeColor',[0.6 0.6 0.6]);
    ylim([0 1]);
    %%
    %     line(get(gca, 'xlim'), [0.95 0.95], 'color', 'k');
    %     line(get(gca, 'xlim'), [0.75 0.75], 'color', 'k');
    
    Experiments.Diss.figures.ReplaceOptsToPrintable
    outfile = sprintf('%s%s_quality_statistics.png', outdir, opts.eval_name);
    saveas(gcf, outfile);
%     open(outfile);
    %%
    % Figures.makeFigure(sprintf('%s_quality_statistics', opts.eval_name), '5cm');
    % matlab2tikz(sprintf('export/%s_quality_statistics.tikz', opts.eval_name));
    %%%
    % set texts
    %opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it' 'gco', 'gcss', 'gsss', 'stcm', 'mspqm'};
    % opt_names = [opt_names {'bspqm'}];
    % opt_names = [opt_names {'mspqm_rpd', 'bspqm_rpd'}];
    
    title(sprintf('%s qualities', opts.eval_name), 'interpreter', 'none');
    
    figure, boxplot(opts.all_num_sp_selected, 'labels', opts.opt_names, 'colors', [0.4 0.4 0.4], 'symbol', 'k+');
    h = findobj(gcf,'Tag','Outliers');
    % make median lines black and big
    set(findobj(gcf,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);
    
    % make outlier dots gray and big
    set(findobj(gcf,'Tag','Outliers'),'MarkerEdgeColor',[0.6 0.6 0.6]);
    
    title(sprintf('%s sensors', opts.eval_name), 'interpreter', 'none');
    
    Experiments.Diss.figures.ReplaceOptsToPrintable
    outfile = sprintf('%s%s_sensors_statistics.png', outdir, opts.eval_name);
    saveas(gcf, outfile);
%     open(outfile);
end
