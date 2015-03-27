%%
clearvars -except all_eval;
% clearvars -except small_flat conference_room large_flat office_floor
%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
outdir = '..\..\Dissertation\thesis\figures\';

for ideval = 1:numel(eval_names)
    % close all;
%     ideval = 2;
%% DRAW PLOT where sensor positions are valued by number and draw environment accordingly to show
% prefered positions that are choosen. This will be the last of the plots!!!
    eval_name = eval_names{ideval};
    opts = all_eval.(eval_name);
    %%
    opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it' 'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd'};
    
    num_opts = numel(opt_names);
    
    input = Experiments.Diss.(eval_name)(500, 500);
    
%     all_sp_eval = 
    %%
    for idn = 1:num_opts
        opt_name = opt_names{idn};
        if any(strcmp(fieldnames(opts), opt_name))
            %%
            mean_wpn_qualities = nan(2601,1);
            sum_wpn_qualities = nan(2601,1);
            sp_selected_mat = nan(2601,1);
            opt = opts.(opt_name);
            flt_eval = ~cellfun(@isempty, opt);
            
            num_sp= cellfun(@(x) x.num_sp, opt(flt_eval));
            num_wpn = cellfun(@(x) x.num_wpn, opt(flt_eval));
            
            sp_selected = cellfun(@(x) numel(x.sensors_selected), opt(flt_eval));
            %%
            wpn_qualities = cellfun(@(x) x.quality.sum_max/x.all_wpn, opt(flt_eval));
            ids = sub2ind([51, 51], num_sp/10+1, num_wpn/10+1);
            if idn > 2
                wpn_sum_qualities = cellfun(@(x) x.quality.sum, opt(flt_eval) );
                sum_wpn_qualities(ids) = wpn_sum_qualities;
            end
            
            mean_wpn_qualities(ids) = wpn_qualities;
            
            sp_selected_mat(ids) = sp_selected;
            all_mean_wpn_qualities(:, idn)  = mean_wpn_qualities(:);
            all_sum_wpn_qualities(:, idn)  = sum_wpn_qualities(:);
            all_num_sp_selected(:, idn) = sp_selected_mat(:);
        end
    end
  
    
    
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
