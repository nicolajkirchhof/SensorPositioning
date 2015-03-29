
%%
clearvars -except all_eval*;
% clearvars -except small_flat conference_room large_flat office_floor
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
%%
figure;
for ideval = 1:numel(eval_names)
    % ideval = 4;
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    
    %%
    opt_names = {'CMQM\\(NL)', 'CMQM\\(CMAES)', 'GCO', 'GCSS', 'GSSS', 'STCM', 'MSPQM', 'BSPQM', 'RPD\\(MSPQM)', 'RPD\\(BSPQM)'};
    %                  1                 2            3      4       5       6        7        8         9            10           11                 12
    subplot(2, 2, ideval);
    boxplot(opts.all_mean_wpn_qualities, 'labels', opt_names, 'colors', [0.4 0.4 0.4], 'symbol', 'k+');
    h = findobj(gcf,'Tag','Outliers');
    % make median lines black and big
    set(findobj(gcf,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);
    
    % make outlier dots gray and big
    set(findobj(gcf,'Tag','Outliers'),'MarkerEdgeColor',[0.6 0.6 0.6]);
    
%     title(sprintf('%s qualities', eval_name), 'interpreter', 'none');
    
    
end
%%
        filename = sprintf('BarglyphFirst%s.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
        matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '4cm',...
        'width', '10cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    
    find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');
    find_and_replace(full_filename,'bar\ shift=.\d.\d*cm,', '');
    find_and_replace(full_filename,'bar\ shift=\d.\d*cm,', ''); 
    find_and_replace(full_filename,'inner\ sep=0mm', 'inner sep=2pt');
    find_and_replace(full_filename,'\ tick\ label\/\.append\ style=\{font=\\color\{black\}\},', ' tick label/.append style={font=\\color{black}, align=center},');
%     find_and_replace(full_filename,'xlabel={\[\\\#\$WPN\$\]},', 'xlabel={[\\#$WPN$]},\nevery axis x label/.style={at={(current axis.south west)},anchor=north },');
%     find_and_replace(full_filename, 'ylabel={\[\\#\$SP\$\]}', 'ylabel={[\\#$SP$]},\nevery axis y label/.style={at={(current axis.north west)},anchor=north east}');
    % xlabel={\#$WPN$},
    %every axis x label/.style={at={(current axis.south east)},anchor=north east },
    % every axis y label/.style={at={(current axis.above origin)},anchor=north east}
    
%     find_and_replace(full_filename,'legend\ style=\{at=\{\(\d.\d*,\d.\d*\)\}', 'legend style={at={(-0.148,7.2)}');
    
    Figures.compilePdflatex(filename, true);  


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