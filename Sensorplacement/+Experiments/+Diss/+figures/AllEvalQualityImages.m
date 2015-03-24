%% Draw All evaluation Properties
%%
clearvars -except all_eval;
% clearvars -except small_flat conference_room large_flat office_floor
%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
close all
for ideval = 1:numel(eval_names)
    %%
%     ideval = 1;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    
  
    %%
    gray_colorline = linspace(0,0.8,100)';
    gray_colormap = repmat(gray_colorline, 1, 3);

    for idopt = 3:6
        %%
       imdata = opts.all_mean_wpn_qualities(:, idopt);
       imlength = sqrt(numel(imdata));
       imdata = reshape(imdata, imlength, imlength);
      
       figure;
       subplot(1, 2, 1);
       xy = 0:10:10*(imlength-1);
       imagesc(xy, xy, imdata);
       colormap(gray_colormap);
%        caxis([0.75 0.95]);
       set(gca, 'YDir', 'normal');
       xlabel('$\#WPN$', 'interpreter', 'none');
       ylabel('$\#SP$', 'interpreter', 'none');
       title(sprintf('%s\n%s qualities', opts.eval_name, opts.opt_names{idopt}), 'interpreter', 'none');
       axis equal
       set(gca, 'xlim', [0 500], 'ylim', [0 500])
       
       imdata = opts.all_num_sp_selected(:, idopt);
       imlength = sqrt(numel(imdata));
       imdata = reshape(imdata, imlength, imlength);
       
%        figure;
       subplot(1, 2, 2);
       xy = 0:10:10*(imlength-1);
       imagesc(xy, xy, imdata);
       colormap(gray_colormap);
%        caxis([0.75 0.95]);
       set(gca, 'YDir', 'normal');
       xlabel('$\#WPN$', 'interpreter', 'none');
       ylabel('$\#SP$', 'interpreter', 'none');
       title(sprintf('%s\n%s number of sp', opts.eval_name, opts.opt_names{idopt}), 'interpreter', 'none');
       axis equal
       set(gca, 'xlim', [0 500], 'ylim', [0 500])
    end

end