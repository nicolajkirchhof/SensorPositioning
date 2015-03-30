%%
% load tmp\all_eval
% load tmp\all_eval_ceaned
clearvars -except all_eval*;
% clearvars -except small_flat conference_room large_flat office_floor
%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
outdir = '..\..\Dissertation\thesis\figures\';
%%
for ideval = 1:numel(eval_names)
    % close all;
    %     ideval = 2;
    %% DRAW PLOT where sensor positions are valued by number and draw environment accordingly to show
    % prefered positions that are choosen. This will be the last of the plots!!!
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    %%%
    opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it' 'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd'};
    
    num_opts = numel(opt_names);
    
    fun_round_ang = @(x)floor(x*1e4)/1e4;
    
    fun_unique_id = @(x) fun_round_ang(x(:,3))*1e6+x(:, 1)*1e2+x(:, 2);
    
    input = Experiments.Diss.(eval_name)(500, 500);
    sp_unique = input.discretization.sp';
    sp_uuids = fun_unique_id(sp_unique);
    sp_stats = zeros(numel(sp_uuids), num_opts-2);
%%
cnt = 1;
    for idn = 3:num_opts
        %%
        opt_name = opt_names{idn};
        if any(strcmp(fieldnames(opts), opt_name))
            %%
            opt = opts.(opt_name);
            flt_eval = ~cellfun(@isempty, opt);
            
            ids_cell = cellfun(@(x) fun_unique_id(x.discretization.sp'), opt(flt_eval), 'uniformoutput', false);
            ids = cell2mat(ids_cell);
           
%             sp_stats(:, cnt) = sum( bsxfun(@eq, sp_uuids, ids'), 2 )/sum(flt_eval(:));
            sp_stats(:, cnt) = sum( bsxfun(@eq, sp_uuids, ids'), 2 )/numel(ids);
            cnt = cnt+1;
        end
    end
    
    %%
    all_eval_cleaned.(eval_name).sp_stats = sp_stats;
    

end
%%
% pct_min = 0.01;
  for ideval = 1:4;
%     ideval = 1;
    eval_name = eval_names{ideval};
    input = Experiments.Diss.(eval_name)(500, 500);
    sp_unique = input.discretization.sp';
    sp_unique(:, 3) = sp_unique(:, 3) + deg2rad(input.config.discretization.sensor.fov/2);

    sp_stats = all_eval_cleaned.(eval_name).sp_stats;
%     sp_stats_clean = sp_stats(any(sp_stats, 2), :);
    sp_stats_mean = sum(sp_stats,2)/sum(sp_stats(:));
    pct_min = mean(sp_stats(sp_stats>0));
    pct_85 = prctile(sp_stats(sp_stats>0), 85);
%     pct_95 = prctile(sp_stats(sp_stats>0), 95);
%     figure, plot(sp_stats_clean, '.');
    figure, bar(sp_stats_mean, 'k');
    hold on;
    xlabel('Id of SP');
    ylabel('wpct [\%]', 'interpreter', 'none');
%     plot(xlim, [pct_95 pct_95], 'k--')
    plot(xlim, [pct_85 pct_85], 'k--')
%     plot(xlim, [pct_min pct_min], 'k--')
%     title(sprintf('%s %g pct_min %g 85 pct', all_eval.(eval_name).name, pct_min, pct_85))
    filename = sprintf('SpStats%sBar.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
        matlab2tikz(full_filename, 'parseStrings', false,...
...         'height', '5cm',...
        'width', '5cm',...
...        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    Figures.compilePdflatex(filename, true);
    %%
    figure;
    Environment.draw(input.environment, false);
    hold on;
    num_sp = sum(sp_stats_mean>pct_85);
    mb.drawPose(sp_unique(sp_stats_mean>pct_85, :)', 'color', 0.5*ones(1,3), 'linewidth', 2, 'markerfacecolor', 'k');
%     title(sprintf('%s %d num sp', all_eval.(eval_name).name, num_sp))
    axis auto;
    axis equal;
    axis off;
    filename = sprintf('SpStats%sEnv.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
        matlab2tikz(full_filename, 'parseStrings', false,...
...        'height', '5cm',...
        'width', '5cm',...
...        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    Figures.compilePdflatex(filename, true);
  end

%%
% matlab2tikz('export\SmallFlatWpnCoverageNumSp.tikz', 'parseStrings', false,...
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-', 'extraAxisOptions',{'y post scale=1'});

matlab2tikz('export\SmallFlatWpnCoverageNumSp.tikz', 'parseStrings', false,...
    'tikzFileComment', '% -*- root: SmallFlatWpnCoverageNumSp.tex -*-',...
    'extraAxisOptions',{'y post scale=1',...
    'every x tick label/.append style={tickwidth=0cm,major tick length=0cm}'});
%     'standalone', true);
%     'every outer x axis line/.append style={black}'});


find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar width=0.025453in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=-0.063633in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=-0.031817in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=0.031817in,', '');
find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','bar shift=0.063633in,', '');
% find_and_replace('export\SmallFlatWpnCoverageNumSp.tikz','area legend,', 'major x tick style = transparent,');

Figures.writeTexFile('SmallFlatWpnCoverageNumSp.tikz', 'export\');


%%
