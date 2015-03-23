%% Draw All evaluation Properties
%%
clearvars -except all_eval;
% clearvars -except small_flat conference_room large_flat office_floor
%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};

for ideval = 1:numel(eval_names)
    %%
%     ideval = 1;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    
  
    %%
    gray_colorline = linspace(0,0.8,100)';
    gray_colormap = repmat(gray_colorline, 1, 3);

    for idopt = 1:size(opts.all_mean_wpn_qualities, 2)
        %%
       imdata = opts.all_mean_wpn_qualities(:, idopt);
       imlength = sqrt(numel(imdata));
       imdata = reshape(imdata, imlength, imlength);
%        imdata_scaled = (imdata-0.75)*4; % scale to 0.8 - 0
%        imdata_scaled(imdata_scaled < 0) = 0;
%        imdata_scaled = 0.8 - imdata_scaled;
       
       figure;
       xy = 0:10:10*(imlength-1);
       imagesc(xy, xy, imdata);
       colormap(gray_colormap);
       caxis([0.75 0.95]);
       set(gca, 'YDir', 'normal');
       xlabel('$\#WPN$', 'interpreter', 'none');
       ylabel('$\#SP$', 'interpreter', 'none');
       title(sprintf('%s\n%s qualities', opts.eval_name, opts.opt_names{idopt}), 'interpreter', 'none');
      
    end
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

end