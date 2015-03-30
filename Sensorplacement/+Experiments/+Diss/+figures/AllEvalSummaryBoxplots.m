%% Draw All evaluation Properties
%%
clearvars -except all_eval*;
% clearvars -except small_flat conference_room large_flat office_floor
%%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
outdir = '..\..\Dissertation\thesis\figures\';
% opt_names = {'CMQM\\(NL)', 'CMQM\\(CMAES)', 'GCO', 'GCSS', 'GSSS', 'STCM', 'MSPQM', 'BSPQM', 'RPD\\(MSPQM)', 'RPD\\(BSPQM)'};
opt_names_print = {'{\scriptsize A}', '{\scriptsize B}', '{\scriptsize C}', '{\scriptsize D}', '{\scriptsize E}', '{\scriptsize F}', '{\scriptsize G}', '{\scriptsize H}', '{\scriptsize I}'};%, '{\scriptsize J}'};
%%
for ideval = 1:numel(eval_names)
%%
export = true;
% ideval = 1;
eval_name = eval_names{ideval};
opts = all_eval.(eval_name);
%%%
% Preevaluation of all data
% valid_flt = all_num_sp_selected >0;
%'medianstyle', 'target',  'boxstyle', 'filled'
figure, boxplot(opts.all_mean_wpn_qualities(:, [1:5 7:10])*100, 'labels', opt_names_print, 'colors', [0.4 0.4 0.4], 'symbol', 'k+');
h = findobj(gcf,'Tag','Outliers');
% make median lines black and big
set(findobj(gcf,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);

% make outlier dots gray and big
set(findobj(gcf,'Tag','Outliers'),'MarkerEdgeColor',[0.6 0.6 0.6]);
ylim([70 100]);
set(gca, 'ytick', 70:5:95);
%%%
%     line(get(gca, 'xlim'), [0.95 0.95], 'color', 'k');
%     line(get(gca, 'xlim'), [0.75 0.75], 'color', 'k');

Experiments.Diss.figures.ReplaceOptsToPrintable

txt    = findall(gcf,'type','text'); % get x-tick-label handles
delete(txt)                          % erase handles
ylabel('[\%]', 'interpreter', 'none');
% set x tick labels :
for i=1:size(opt_names_print,2)                 % number of box plot bars in figure
    text('Interpreter','none',...
        'String',opt_names_print{i},...
        'Units','normalized',...
        'VerticalAlignment','top',...
        'HorizontalAlignment','center',...
        'Position',[1/(size(opt_names_print,2)*2)*(1+2*(i-1)),-0.01],...x/y position
        'EdgeColor','none')
end

filename = sprintf('EvalSummayBoxplotsQuality%s.tex', eval_name);
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '3cm',...
    'width', '3cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
find_and_replace(full_filename, 'ylabel={\[\\%\]}', 'ylabel={\[\\%\]},\nevery axis y label/.style={at={(current axis.north west)},anchor=east}');

Figures.compilePdflatex(filename, export, false);


%%
title(sprintf('%s qualities', opts.eval_name), 'interpreter', 'none');

figure, boxplot(opts.all_num_sp_selected(:, [1:5 7:10]), 'labels', opt_names_print, 'colors', [0.4 0.4 0.4], 'symbol', 'k+');
h = findobj(gcf,'Tag','Outliers');
% make median lines black and big
set(findobj(gcf,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);

% make outlier dots gray and big
set(findobj(gcf,'Tag','Outliers'),'MarkerEdgeColor',[0.6 0.6 0.6]);

% title(sprintf('%s sensors', opts.eval_name), 'interpreter', 'none');

Experiments.Diss.figures.ReplaceOptsToPrintable

txt    = findall(gcf,'type','text'); % get x-tick-label handles
delete(txt)                          % erase handles
ylabel('[\#$SP$]', 'interpreter', 'none');
if ideval == 1 
    ylim([3 13]);
elseif ideval==3
    ylim([15 65]);
end
% set x tick labels :
for i=1:size(opt_names_print,2)                 % number of box plot bars in figure
    text('Interpreter','none',...
        'String',opt_names_print{i},...
        'Units','normalized',...
        'VerticalAlignment','top',...
        'HorizontalAlignment','center',...
        'Position',[1/(size(opt_names_print,2)*2)*(1+2*(i-1)),-0.01],...x/y position
        'EdgeColor','none')
end

filename = sprintf('EvalSummayBoxplotsSp%s.tex', eval_name);
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '3cm',...
    'width', '3cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);
find_and_replace(full_filename, 'ylabel={\[\\#\$SP\$\]}', 'ylabel={[\\#$SP$]},\nevery axis y label/.style={at={(current axis.north west)},anchor=east}');


Figures.compilePdflatex(filename, export, false);

%%
title(sprintf('%s qualities', opts.eval_name), 'interpreter', 'none');

figure, boxplot(opts.all_area_covered_pct(:, [1:5 7:10]), 'labels', opt_names_print, 'colors', [0.4 0.4 0.4], 'symbol', 'k+');
h = findobj(gcf,'Tag','Outliers');
% make median lines black and big
set(findobj(gcf,'Tag','Median'),'Color',[0 0 0],'LineWidth',2);

% make outlier dots gray and big
set(findobj(gcf,'Tag','Outliers'),'MarkerEdgeColor',[0.6 0.6 0.6]);

% title(sprintf('%s sensors', opts.eval_name), 'interpreter', 'none');
Experiments.Diss.figures.ReplaceOptsToPrintable

txt    = findall(gcf,'type','text'); % get x-tick-label handles
delete(txt)                          % erase handles
ylabel('[\%]', 'interpreter', 'none');
ylim([35 100]);
set(gca, 'ytick', 40:10:90);
%%%
% set x tick labels :
for i=1:size(opt_names_print,2)                 % number of box plot bars in figure
    text('Interpreter','none',...
        'String',opt_names_print{i},...
        'Units','normalized',...
        'VerticalAlignment','top',...
        'HorizontalAlignment','center',...
        'Position',[1/(size(opt_names_print,2)*2)*(1+2*(i-1)),-0.01],...x/y position
        'EdgeColor','none')
end

filename = sprintf('EvalSummayBoxplotsAreaCov%s.tex', eval_name);
full_filename = sprintf('export/%s', filename);
matlab2tikz(full_filename, 'parseStrings', false,...
    'height', '3cm',...
    'width', '3cm',...
    'extraCode', '\standaloneconfig{border=0.1cm}',...
    'standalone', true);

find_and_replace(full_filename, 'ylabel={\[\\%\]}', 'ylabel={\[\\%\]},\nevery axis y label/.style={at={(current axis.north west)},anchor=east}');

if ideval == 4
    Figures.compilePdflatex(filename, export, true);
else
    Figures.compilePdflatex(filename, export, false);
end

end
