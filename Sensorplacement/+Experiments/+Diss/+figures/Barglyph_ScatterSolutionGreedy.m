%%
clearvars -except all_eval;
% clearvars -except small_flat conference_room large_flat office_floor
%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
outdir = '..\..\Dissertation\thesis\figures\';
close all;
% for ideval = 1:numel(eval_names)
    % close all;
    ideval = 1;
    eval_name = eval_names{ideval};
    
    [X, Y] = meshgrid(0:10:500, 0:10:500);
    range = 1:1:51;
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
    
    all_mean_wpn_qualities_rounded = round(all_eval.(eval_name).all_mean_wpn_qualities*100);
    real_num_sp = zeros(size(all_x));
    real_num_wpn = zeros(size(all_x));
    for idxy = 1:numel(all_x)
        input = Experiments.Diss.(eval_name)(all_x(idxy), all_y(idxy));
        real_num_sp(idxy) = input.discretization.num_sensors;
        real_num_wpn(idxy) = input.discretization.num_positions;
    end
    
    figure;
    h0 = barglyph(xlist, ylist, height, width, all_mean_wpn_qualities_rounded(ind, 3:5), xrange, yrange);
    
    strlabelsx = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_x, real_num_sp, 'uniformoutput', false);
    strlabelsy = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_y, real_num_wpn, 'uniformoutput', false);
    set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
    xlabel(h0,'\#$WPN$', 'interpreter', 'none');
    ylabel(h0, '\#$SP$', 'interpreter', 'none');
    title(h0, 'Mean of max Qualities [%]');
    h = legend({'GCO', 'GCSS', 'GSSS'},'Location', 'SouthOutside', 'Orientation','horizontal' );
    pos = get(h, 'position');
    set(h, 'position', [0.25 0 0.5 0.05])
    set(gcf, 'position', [0 0 1920 1080]);
    
%     outfile = sprintf('%s%s_greedy_comparison_quality.png', outdir, opts.eval_name);
%     saveas(gcf, outfile);

    
        filename = sprintf('BarglyphGreedy%s.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
        matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '10cm',...
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
    h0 = barglyph(xlist, ylist, height, width, all_eval.(eval_name).all_num_sp_selected(ind, 3:5), xrange, yrange);
    
    strlabelsx = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_x, real_num_sp, 'uniformoutput', false);
    strlabelsy = arrayfun(@(x, y) sprintf('%d (%d)', x, y), all_y, real_num_wpn, 'uniformoutput', false);
    set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
    xlabel(h0,'\#$WPN$', 'interpreter', 'none');
    ylabel(h0, '\#$SP$', 'interpreter', 'none');
    title(h0, 'Number of selected sensors');
    h = legend({'GCO', 'GCSS', 'GSSS'},'Location', 'SouthOutside', 'Orientation','horizontal' );
    pos = get(h, 'position');
    set(h, 'position', [0.25 0 0.5 0.05])
    set(gcf, 'position', [0 0 1920 1080]);
    
    outfile = sprintf('%s%s_greedy_comparison_num_sp.png', outdir, opts.eval_name);
    saveas(gcf, outfile);
    
    
    
% end

%%
