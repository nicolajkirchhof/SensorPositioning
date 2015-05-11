
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
opt_names = {'gco_i', 'gcss', 'gsss'};
close all;

for ideval = 1:numel(eval_names)
    %%
    %     ideval = 1;
    eval_name = eval_names{ideval};
    %     opts = all_eval.(eval_name);
    diffsp = all_eval.(eval_name).all_num_sp_selected(:, 3:5)-all_eval.(eval_name).greedy_it_num_sp_selected(:, 1:3);
    fprintf('%s mean sco = %g, gcss = %g, gsss = %g\n', eval_name,  mean(diffsp));
end
%%
for ideval = 1:numel(eval_names)
    %%
    %     ideval = 1;
    eval_name = eval_names{ideval};
    %     opts = all_eval.(eval_name);
    diffsp = all_eval.(eval_name).all_num_sp_selected(:, 3:5)-all_eval.(eval_name).greedy_it_num_sp_selected(:, 1:3);
    [diffsortsp, idsort] = sort(diffsp, 1);
    figure
    
    hist(diffsp);
    ylim([0 2200]);
%     if ideval == 1
%     legend({'GSSS', 'GCS', 'GCSC'},'Orientation','horizontal', 'Location', 'Northoutside')
%     end
    h = findobj(gca,'Type','patch');
    % legend('mspqm','bspqm')
    set(h(1), 'facecolor', 0.9*ones(1,3))
    set(h(2), 'facecolor', 0.5*ones(1,3))
    set(h(3), 'facecolor', 0.2*ones(1,3))
    
    ylabel('$\#$Solutions', 'interpreter', 'none');
    
    if ideval == 4
        xlabel('$\Delta \# SP$', 'interpreter', 'none');
    end
    
    % clf
    % cla
%     hold on
%     %     colors = linspace
%     %         bar(diffsortsp, 'facecolor', );
%     gnumsp= all_eval.(eval_name).all_num_sp_selected(:, 3:5);
%     cmap = [0 0.3 0.6]';
%     h = plot(gnumsp(idsort), '.s', 'markersize', 5);
%     if ideval == 1
%         legend({'GCSC', 'GCS', 'GSSS'},'Orientation','horizontal', 'Location', 'Northoutside')
%     end
%     delete(h)
%        
%     for idcol = 1:size(diffsp, 2)
%         %%
%         ply = [[(1:2601)' diffsortsp(:,idcol)];[2601 0];[0 0]];
%         sply = simplifyPolyline(ply, 0.1);
%       
%         fillPolygon(sply, cmap(idcol)*ones(1,3));
% %         set(h(idcol), 'color', cmap(idcol)*ones(1,3));
%     end
%     xlim([0 2600])
%     ylabel('[\#]', 'interpreter', 'none');
%     if ideval == 1
%         set(gca, 'YTick', 0:2:8);
%     end
%     set(gca, 'XTick', []);

    filename = sprintf('GreedyIt%s.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
    matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '2cm',...
        'width', '10cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
%     if ideval == 4
%         
%     filename = sprintf('GreedyIt%s.tex', eval_name);
%     full_filename = sprintf('export/%s', filename);
%     matlab2tikz(full_filename, 'parseStrings', false,...
%         'height', '3cm',...
%         'width', '10cm',...
%         'extraCode', '\standaloneconfig{border=0.1cm}',...
%         'standalone', true);
%     end
%     end
%     find_and_replace(full_filename, 'ylabel={\[\\#\]}', 'ylabel={[\\#SP]},\nevery axis y label/.style={at={(current axis.north west)},anchor=east}');
%     find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');
%     find_and_replace(full_filename,'bar\ shift=.\d.\d*cm,', '');
%     find_and_replace(full_filename,'bar\ shift=\d.\d*cm,', '');
%     find_and_replace(full_filename,'inner\ sep=0mm', 'inner sep=1pt');
    Figures.compilePdflatex(filename, true, false);
end
%%
clc
for ideval = 1:numel(eval_names)
    %%
    %     ideval = 1;
    eval_name = eval_names{ideval};
    gcsVsco = diff(all_eval.(eval_name).all_num_sp_selected(:, (3:4)), 1, 2);
    gsssVgcs = diff(all_eval.(eval_name).all_num_sp_selected(:, (4:5)), 1, 2);
    gsssVsco = diff(all_eval.(eval_name).all_num_sp_selected(:, ([3,5])), 1, 2);

    fprintf('====== %s before =======\n', all_eval.(eval_name).name)
    fprintf('Mean gcsVsco = %g, gsssVgcs = %g, gsssVsco = %g\n', mean(gcsVsco), mean(gsssVgcs), mean(gsssVsco) );
    fprintf('Max gcsVsco = %d, gsssVgcs = %d, gsssVsco = %d\n', max(gcsVsco), max(gsssVgcs), max(gsssVsco) );
    fprintf('NumWin gcsVsco = %g, gsssVgcs = %g, gsssVsco = %g\n', sum(gcsVsco<0), sum(gsssVgcs<0), sum(gsssVsco<0) );
    fprintf('NumLoose gcsVsco = %d, gsssVgcs = %d, gsssVsco = %d\n', sum(gcsVsco>0), sum(gsssVgcs>0), sum(gsssVsco>0) );
    fprintf('NumEqual gcsVsco = %d, gsssVgcs = %d, gsssVsco = %d\n', sum(gcsVsco==0), sum(gsssVgcs==0), sum(gsssVsco==0) );

    
    
    gcsVITsco = diff(all_eval.(eval_name).greedy_it_num_sp_selected(:, (1:2)), 1, 2);
    gsssVITgcs = diff(all_eval.(eval_name).greedy_it_num_sp_selected(:, (2:3)), 1, 2);
    gsssVITsco = diff(all_eval.(eval_name).greedy_it_num_sp_selected(:, ([1,3])), 1, 2);

    fprintf('====== %s before =======\n', all_eval.(eval_name).name)
    fprintf('Mean gcsVsco = %g, gsssVgcs = %g, gsssVsco = %g\n', mean(gcsVITsco), mean(gsssVITgcs), mean(gsssVITsco) );
    fprintf('Max gcsVsco = %d, gsssVgcs = %d, gsssVsco = %d\n', max(gcsVITsco), max(gsssVITgcs), max(gsssVITsco) );
    fprintf('NumWin gcsVsco = %g, gsssVgcs = %g, gsssVsco = %g\n', sum(gcsVITsco<0), sum(gsssVITgcs<0), sum(gsssVITsco<0) );
    fprintf('NumLoose gcsVsco = %d, gsssVgcs = %d, gsssVsco = %d\n', sum(gcsVITsco>0), sum(gsssVITgcs>0), sum(gsssVITsco>0) );
    fprintf('NumEqual gcsVsco = %d, gsssVgcs = %d, gsssVsco = %d\n', sum(gcsVITsco==0), sum(gsssVITgcs==0), sum(gsssVITsco==0) );

    fprintf('\n\n\n');
    
   
end
%%
clc
for ideval = 1:numel(eval_names)
    %%
    %     ideval = 1;
    eval_name = eval_names{ideval};
    gsp = all_eval.(eval_name).all_num_sp_selected(:, (3:5)) ;
    gitsp = all_eval.(eval_name).greedy_it_num_sp_selected;
    diffsp = all_eval.(eval_name).all_num_sp_selected(:, 3:5)-all_eval.(eval_name).greedy_it_num_sp_selected(:,1:3);
    fprintf('====== %s =======\n', all_eval.(eval_name).name)
    fprintf('Mean improvement sco = %g, gcss = %g, gsss = %g\n', nanmean(diffsp, 1));
    fprintf('Max improvement sco = %d, gcss = %d, gsss = %d\n', nanmax(diffsp, [], 1));
%     fprintf('=== Mean Diff before Greedy ===\n');
    fprintf('Mean diff before sco - gcss = %d, gcss - gsss  = %g, sco - gsss = %g\n', -mean(diff(gsp, 1, 2)),  -mean(diff(gsp(:, [1,3]),1,2)));
%     fprintf('=== Mean Diff after Greedy ===\n');
    fprintf('Mean diff after sco - gcss = %d, gcss - gsss  = %g, sco - gsss = %g\n', -mean(diff(gitsp, 1, 2)), -mean(diff(gitsp(:, [1,3]),1,2)));

end