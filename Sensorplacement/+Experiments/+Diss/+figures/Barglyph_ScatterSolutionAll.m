%%
clearvars -except all_eval*;
% clearvars -except small_flat conference_room large_flat office_floor
%%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
outdir = '..\..\Dissertation\thesis\figures\';
%%%
for ideval = 1:2
    %%%
    close all;
%     ideval = 1;
    eval_name = eval_names{ideval};
    
    [X, Y] = meshgrid(0:10:500, 0:10:500);
    range = 1:5:21;
    [idx, idy] = meshgrid(range, range);
    ind = sub2ind([51 51], idx(:), idy(:));
    
    xlist = X(ind);
    ylist = Y(ind);
    height = 31;
    width = 38;
    xrange = [-30 230];
    yrange = [-30 230];
    
    all_x = unique(xlist);
    all_y = unique(ylist);
    
    all_mean_wpn_qualities_rounded = round(all_eval.(eval_name).all_mean_wpn_qualities*100);
    all_sum_qualities = all_eval.(eval_name).all_sum_wpn_qualities;
    all_area_covered_pct =  all_eval.(eval_name).all_area_covered_pct;
%     all_sum_qualities(:, [1:6 9:10]) = nan;
    real_num_sp = zeros(size(all_x));
    real_num_wpn = zeros(size(all_x));
    for idxy = 1:numel(all_x)
        input = Experiments.Diss.(eval_name)(all_x(idxy), all_y(idxy));
        real_num_sp(idxy) = input.discretization.num_sensors;
        real_num_wpn(idxy) = input.discretization.num_positions;
    end
    
    figure;
    if ideval == 1
        [h0 h1out] = barglyph3values(xlist, ylist, height, width, all_eval.(eval_name).all_num_sp_selected(ind, [3:5 7:8]),... 
            all_mean_wpn_qualities_rounded(ind, [3:5 7:8]), xrange, yrange, all_sum_qualities(ind, [3:5 7:8]), all_area_covered_pct(ind, [3:5 7:8]));
    else
        [h0 h1out] = barglyph3values(xlist, ylist, height, width, all_eval.(eval_name).all_num_sp_selected(ind, [3:5 7:10]),...
            all_mean_wpn_qualities_rounded(ind, [3:5 7:10]), xrange, yrange, all_sum_qualities(ind, [3:5 7:10]), all_area_covered_pct(ind, [3:5 7:10]));
    end
    
    strlabelsx = arrayfun(@(x, y) sprintf('%d\\\\(%d)', x, y), all_x, real_num_wpn, 'uniformoutput', false);
    strlabelsy = arrayfun(@(x, y) sprintf('%d\\\\(%d)', x, y), all_y, real_num_sp, 'uniformoutput', false);
    set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
    xlabel(h0,'[\#$WPN$]', 'interpreter', 'none');
    ylabel(h0, '[\#$SP$]', 'interpreter', 'none');
%     title(h0, sprintf('%s\\newline Number of Sensors', all_eval.(eval_name).name));
    h = legend(h1out, {'GSCS', 'GCS', 'GSSS', 'MSPQM', 'BSPQM', 'RPD (MSPQM)', 'RPD (BSPQM)'},'Location', 'SouthOutside', 'Orientation','horizontal' );
    pos = get(h, 'position');
    set(h, 'position', [0.25 0 0.5 0.05]);
    set(gcf, 'position', [0 0 1920 1080]);
    %%%
        filename = sprintf('BarglyphAll%s.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
        matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '11cm',...
        'width', '20cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    
    find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');
    find_and_replace(full_filename,'bar\ shift=.\d.\d*cm,', '');
    find_and_replace(full_filename,'bar\ shift=\d.\d*cm,', ''); 
    find_and_replace(full_filename,'inner\ sep=0mm', 'inner sep=1pt');
    find_and_replace(full_filename,'\ tick\ label\/\.append\ style=\{font=\\color\{black\}\},', ' tick label/.append style={font=\\color{black}, align=center},');
    find_and_replace(full_filename,'xlabel={\[\\\#\$WPN\$\]},', 'xlabel={[\\#$WPN$]},\nevery axis x label/.style={at={(current axis.south east)},anchor=north east },');
    find_and_replace(full_filename, 'ylabel={\[\\#\$SP\$\]}', 'ylabel={[\\#$SP$]},\nevery axis y label/.style={at={(current axis.north west)},anchor=north east}');
    % xlabel={\#$WPN$},
    %every axis x label/.style={at={(current axis.south east)},anchor=north east },
    % every axis y label/.style={at={(current axis.above origin)},anchor=north east}
    
    find_and_replace(full_filename,'legend\ style=\{at=\{\(\d.\d*,\d.\d*\)\}', 'legend style={at={(-0.135,6.5)}');
    
    Figures.compilePdflatex(filename, true, false);
end
%%%
    close all;
    ideval = 3;
    eval_name = eval_names{ideval};
    
    [X, Y] = meshgrid(0:10:500, 0:10:500);
    range = 1:5:11;
    [idx, idy] = meshgrid(range, range);
    ind = sub2ind([51 51], idx(:), idy(:));
    
    xlist = X(ind);
    ylist = Y(ind);
    height = 31;
    width = 38;
    xrange = [-30 130];
    yrange = [-30 130];
    
    all_x = unique(xlist);
    all_y = unique(ylist);
    
    all_mean_wpn_qualities_rounded = round(all_eval.(eval_name).all_mean_wpn_qualities*100);
    all_sum_qualities = all_eval.(eval_name).all_sum_wpn_qualities;
    all_area_covered_pct =  all_eval.(eval_name).all_area_covered_pct;
%     all_sum_qualities(:, [1:6 9:10]) = nan;
    real_num_sp = zeros(size(all_x));
    real_num_wpn = zeros(size(all_x));
    for idxy = 1:numel(all_x)
        input = Experiments.Diss.(eval_name)(all_x(idxy), all_y(idxy));
        real_num_sp(idxy) = input.discretization.num_sensors;
        real_num_wpn(idxy) = input.discretization.num_positions;
    end
    
    figure;
        [h0 h1out] = barglyph3values(xlist, ylist, height, width, all_eval.(eval_name).all_num_sp_selected(ind, [3:5 7:9]),...
            all_mean_wpn_qualities_rounded(ind, [3:5 7:9]), xrange, yrange, all_sum_qualities(ind, [3:5 7:9]), all_area_covered_pct(ind, [3:5 7:10]));
   
    strlabelsx = arrayfun(@(x, y) sprintf('%d\\\\(%d)', x, y), all_x, real_num_wpn, 'uniformoutput', false);
    strlabelsy = arrayfun(@(x, y) sprintf('%d\\\\(%d)', x, y), all_y, real_num_sp, 'uniformoutput', false);
    set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
    xlabel(h0,'[\#$WPN$]', 'interpreter', 'none');
    ylabel(h0, '[\#$SP$]', 'interpreter', 'none');
%     title(h0, sprintf('%s\\newline Number of Sensors', all_eval.(eval_name).name));
    h = legend(h1out, {'GSCS', 'GCS', 'GSSS', 'MSPQM', 'BSPQM', 'RPD (MSPQM)', 'RPD (BSPQM)'},'Location', 'SouthOutside', 'Orientation','horizontal' );
    pos = get(h, 'position');
    set(h, 'position', [0.25 0 0.5 0.05]);
    set(gcf, 'position', [0 0 1920 1080]);
    %%%
        filename = sprintf('BarglyphAll%sexcerpt.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
        matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '6cm',...
        'width', '11cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    
    find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');
    find_and_replace(full_filename,'bar\ shift=.\d.\d*cm,', '');
    find_and_replace(full_filename,'bar\ shift=\d.\d*cm,', ''); 
    find_and_replace(full_filename,'inner\ sep=0mm', 'inner sep=1pt');
    find_and_replace(full_filename,'\ tick\ label\/\.append\ style=\{font=\\color\{black\}\},', ' tick label/.append style={font=\\color{black}, align=center},');
    find_and_replace(full_filename,'xlabel={\[\\\#\$WPN\$\]},', 'xlabel={[\\#$WPN$]},\nevery axis x label/.style={at={(current axis.south east)},anchor=north east },');
    find_and_replace(full_filename, 'ylabel={\[\\#\$SP\$\]}', 'ylabel={[\\#$SP$]},\nevery axis y label/.style={at={(current axis.north west)},anchor=north east}');
    % xlabel={\#$WPN$},
    %every axis x label/.style={at={(current axis.south east)},anchor=north east },
    % every axis y label/.style={at={(current axis.above origin)},anchor=north east}
    
    find_and_replace(full_filename,'legend\ style=\{at=\{\(\d.\d*,\d.\d*\)\}', 'legend style={at={(-0.535,3.9)}');
    
    Figures.compilePdflatex(filename, true, false);

%%%
    close all;
    ideval = 3;
    eval_name = eval_names{ideval};
    
    [X, Y] = meshgrid(0:10:500, 0:10:500);
    range = 1:5:21;
    [idx, idy] = meshgrid(range, range);
    ind = sub2ind([51 51], idx(:), idy(:));
    
    xlist = X(ind);
    ylist = Y(ind);
    height = 31;
    width = 38;
    xrange = [-30 230];
    yrange = [-30 230];
    
    all_x = unique(xlist);
    all_y = unique(ylist);
    
    all_mean_wpn_qualities_rounded = round(all_eval.(eval_name).all_mean_wpn_qualities*100);
    all_sum_qualities = all_eval.(eval_name).all_sum_wpn_qualities;
    all_area_covered_pct =  all_eval.(eval_name).all_area_covered_pct;
%     all_sum_qualities(:, [1:6 9:10]) = nan;
    real_num_sp = zeros(size(all_x));
    real_num_wpn = zeros(size(all_x));
    for idxy = 1:numel(all_x)
        input = Experiments.Diss.(eval_name)(all_x(idxy), all_y(idxy));
        real_num_sp(idxy) = input.discretization.num_sensors;
        real_num_wpn(idxy) = input.discretization.num_positions;
    end
    
    figure;
        [h0 h1out] = barglyph3values(xlist, ylist, height, width, all_eval.(eval_name).all_num_sp_selected(ind, [3:5 7:9]),...
            all_mean_wpn_qualities_rounded(ind, [3:5 7:9]), xrange, yrange, all_sum_qualities(ind, [3:5 7:9]), all_area_covered_pct(ind, [3:5 7:10]));
   
    strlabelsx = arrayfun(@(x, y) sprintf('%d\\\\(%d)', x, y), all_x, real_num_wpn, 'uniformoutput', false);
    strlabelsy = arrayfun(@(x, y) sprintf('%d\\\\(%d)', x, y), all_y, real_num_sp, 'uniformoutput', false);
    set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
    xlabel(h0,'[\#$WPN$]', 'interpreter', 'none');
    ylabel(h0, '[\#$SP$]', 'interpreter', 'none');
%     title(h0, sprintf('%s\\newline Number of Sensors', all_eval.(eval_name).name));
    h = legend(h1out, {'GSCS', 'GCS', 'GSSS', 'MSPQM', 'BSPQM', 'RPD (MSPQM)', 'RPD (BSPQM)'},'Location', 'SouthOutside', 'Orientation','horizontal' );
    pos = get(h, 'position');
    set(h, 'position', [0.25 0 0.5 0.05]);
    set(gcf, 'position', [0 0 1920 1080]);
    %%%
        filename = sprintf('BarglyphAll%s.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
        matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '11cm',...
        'width', '20cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    
    find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');
    find_and_replace(full_filename,'bar\ shift=.\d.\d*cm,', '');
    find_and_replace(full_filename,'bar\ shift=\d.\d*cm,', ''); 
    find_and_replace(full_filename,'inner\ sep=0mm', 'inner sep=1pt');
    find_and_replace(full_filename,'\ tick\ label\/\.append\ style=\{font=\\color\{black\}\},', ' tick label/.append style={font=\\color{black}, align=center},');
    find_and_replace(full_filename,'xlabel={\[\\\#\$WPN\$\]},', 'xlabel={[\\#$WPN$]},\nevery axis x label/.style={at={(current axis.south east)},anchor=north east },');
    find_and_replace(full_filename, 'ylabel={\[\\#\$SP\$\]}', 'ylabel={[\\#$SP$]},\nevery axis y label/.style={at={(current axis.north west)},anchor=north east}');
    % xlabel={\#$WPN$},
    %every axis x label/.style={at={(current axis.south east)},anchor=north east },
    % every axis y label/.style={at={(current axis.above origin)},anchor=north east}
    
    find_and_replace(full_filename,'legend\ style=\{at=\{\(\d.\d*,\d.\d*\)\}', 'legend style={at={(-0.135,6.5)}');
    
    Figures.compilePdflatex(filename, true, false);

       %%%
    close all;
    ideval = 4;
    eval_name = eval_names{ideval};
    
    [X, Y] = meshgrid(0:10:500, 0:10:500);
    range = 1:5:21;
    [idx, idy] = meshgrid(range, range);
    ind = sub2ind([51 51], idx(:), idy(:));
    
    xlist = X(ind);
    ylist = Y(ind);
    height = 28;
    width = 37;
    xrange = [-30 230];
    yrange = [-30 230];
    
    all_x = unique(xlist);
    all_y = unique(ylist);
    
    all_mean_wpn_qualities_rounded = round(all_eval.(eval_name).all_mean_wpn_qualities*100);
     all_sum_qualities = all_eval.(eval_name).all_sum_wpn_qualities;
     all_area_covered_pct =  all_eval.(eval_name).all_area_covered_pct;
    real_num_sp = zeros(size(all_x));
    real_num_wpn = zeros(size(all_x));
    for idxy = 1:numel(all_x)
        input = Experiments.Diss.(eval_name)(all_x(idxy), all_y(idxy));
        real_num_sp(idxy) = input.discretization.num_sensors;
        real_num_wpn(idxy) = input.discretization.num_positions;
    end
    
    figure;
    [h0 h1out] = barglyph3values(xlist, ylist, height, width, all_eval.(eval_name).all_num_sp_selected(ind, 3:5),... 
        all_mean_wpn_qualities_rounded(ind, 3:5), xrange, yrange, all_sum_qualities(ind, 3:5), all_area_covered_pct(ind, 3:5));

    
    strlabelsx = arrayfun(@(x, y) sprintf('%d\\\\(%d)', x, y), all_x, real_num_wpn, 'uniformoutput', false);
    strlabelsy = arrayfun(@(x, y) sprintf('%d\\\\(%d)', x, y), all_y, real_num_sp, 'uniformoutput', false);
    set(h0,  'xticklabel', strlabelsx, 'yticklabel', strlabelsy, 'Ticklength', [0 0], 'box', 'on');
    xlabel(h0,'[\#$WPN$]', 'interpreter', 'none');
    ylabel(h0, '[\#$SP$]', 'interpreter', 'none');
%     title(h0, sprintf('%s\\newline Number of Sensors', all_eval.(eval_name).name));
    h = legend(h1out, {'GSCS', 'GCS', 'GSSS', 'MSPQM', 'BSPQM', 'RPD (MSPQM)', 'RPD (BSPQM)'},'Location', 'SouthOutside', 'Orientation','horizontal' );
    pos = get(h, 'position');
    set(h, 'position', [0.25 0 0.5 0.05]);
    set(gcf, 'position', [0 0 1920 1080]);
    %%%
        filename = sprintf('BarglyphAll%s.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
        matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '9cm',...
        'width', '11cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    
    find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');
    find_and_replace(full_filename,'bar\ shift=.\d.\d*cm,', '');
    find_and_replace(full_filename,'bar\ shift=\d.\d*cm,', ''); 
    find_and_replace(full_filename,'inner\ sep=0mm', 'inner sep=2pt');
    find_and_replace(full_filename,'\ tick\ label\/\.append\ style=\{font=\\color\{black\}\},', ' tick label/.append style={font=\\color{black}, align=center},');
    find_and_replace(full_filename,'xlabel={\[\\\#\$WPN\$\]},', 'xlabel={[\\#$WPN$]},\nevery axis x label/.style={at={(current axis.south west)},anchor=north },');
    find_and_replace(full_filename, 'ylabel={\[\\#\$SP\$\]}', 'ylabel={[\\#$SP$]},\nevery axis y label/.style={at={(current axis.north west)},anchor=north east}');
    % xlabel={\#$WPN$},
    %every axis x label/.style={at={(current axis.south east)},anchor=north east },
    % every axis y label/.style={at={(current axis.above origin)},anchor=north east}
    
    find_and_replace(full_filename,'legend\ style=\{at=\{\(\d.\d*,\d.\d*\)\}', 'legend style={at={(-0.148,7.2)}');
    
    Figures.compilePdflatex(filename, true, false);    
%%%
    close all;
    ideval = 4;
    eval_name = eval_names{ideval};
    
    [X, Y] = meshgrid(0:10:500, 0:10:500);
    range = 1;
    [idx, idy] = meshgrid(range, range);
    ind = sub2ind([51 51], idx(:), idy(:));
    
    xlist = X(ind);
    ylist = Y(ind);
    height = 28;
    width = 37;
    xrange = [-30 230];
    yrange = [-30 230];
    
    all_x = unique(xlist);
    all_y = unique(ylist);
    
    all_mean_wpn_qualities_rounded = round(all_eval.(eval_name).all_mean_wpn_qualities*100);
     all_sum_qualities = all_eval.(eval_name).all_sum_wpn_qualities;
    real_num_sp = zeros(size(all_x));
    real_num_wpn = zeros(size(all_x));
    for idxy = 1:numel(all_x)
        input = Experiments.Diss.(eval_name)(all_x(idxy), all_y(idxy));
        real_num_sp(idxy) = input.discretization.num_sensors;
        real_num_wpn(idxy) = input.discretization.num_positions;
    end
    %%%
    figure;
    [h0 h1out] = barglyph3values(xlist, ylist, height, width, all_eval.(eval_name).all_num_sp_selected(ind, [3:5 7 9]),...
        all_mean_wpn_qualities_rounded(ind, [3:5 7 9]), xrange, yrange, all_sum_qualities(ind, [3:5 7 9]), all_eval.(eval_name).all_area_covered_pct(ind, [3:5 7 9]));
    delete(h0);
    set(h1out, 'position', [0.1 0.1 0.8 0.8]);    
    h = legend(h1out, {'GSCS', 'GCS', 'GSSS', 'MSPQM', 'RPD\\(MSPQM)', 'RPD\\(BSPQM)'}, 'Location', 'NorthOutside', 'Orientation','horizontal' );
    pos = get(h, 'position');
%     set(h, 'position', [0 0.95 0.5 0.05]);
%     set(gcf, 'position', [0 0 1920 1080]);
    %%%
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
    
    Figures.compilePdflatex(filename, true, true);   

%%
