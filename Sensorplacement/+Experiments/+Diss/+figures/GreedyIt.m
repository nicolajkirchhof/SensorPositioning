
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
opt_names = {'gco_i', 'gcss', 'gsss'};
close all;

for ideval = 1:numel(eval_names)
    %%
    %     ideval = 1;
    eval_name = eval_names{ideval};
    %     opts = all_eval.(eval_name);
    diffsp = all_eval.(eval_name).all_num_sp_selected(:, 3:5)-all_eval.(eval_name).greedy_it_num_sp_selected;
    [diffsortsp, idsort] = sort(diffsp, 1);
    figure
    % clf
    % cla
    hold on
    %     colors = linspace
    %         bar(diffsortsp, 'facecolor', );
    gnumsp= all_eval.(eval_name).all_num_sp_selected(:, 3:5);
    cmap = [0 0.3 0.6]';
    h = plot(gnumsp(idsort), '.', 'markersize', 5);
       
    for idcol = 1:size(diffsp, 2)
        %%
        ply = [[(1:2601)' diffsortsp(:,idcol)];[2601 0];[0 0]];
        sply = simplifyPolyline(ply, 0.1);
      
        fillPolygon(sply, cmap(idcol)*ones(1,3));
        set(h(idcol), 'color', cmap(idcol)*ones(1,3));
    end
    xlim([0 2600])
    ylabel('[\#]', 'interpreter', 'none');
    if ideval == 1
        set(gca, 'YTick', 0:2:8);
    end
    

    %%
    filename = sprintf('GreedyIt%s.tex', eval_name);
    full_filename = sprintf('export/%s', filename);
    matlab2tikz(full_filename, 'parseStrings', false,...
        'height', '4cm',...
        'width', '10cm',...
        'extraCode', '\standaloneconfig{border=0.1cm}',...
        'standalone', true);
    find_and_replace(full_filename, 'ylabel={\[\\#\]}', 'ylabel={[\\#SP]},\nevery axis y label/.style={at={(current axis.north west)},anchor=east}');
    find_and_replace(full_filename,'bar\ width=\d.\d*cm,', 'bar width=0.8,');
    find_and_replace(full_filename,'bar\ shift=.\d.\d*cm,', '');
    find_and_replace(full_filename,'bar\ shift=\d.\d*cm,', '');
    find_and_replace(full_filename,'inner\ sep=0mm', 'inner sep=1pt');
    Figures.compilePdflatex(filename, true, false);
end
%%
clc
for ideval = 1:numel(eval_names)
    %%
    %     ideval = 1;
    eval_name = eval_names{ideval};
    gsp = all_eval.(eval_name).all_num_sp_selected(:, (3:5)) ;
    gitsp = all_eval.(eval_name).greedy_it_num_sp_selected;
    diffsp = all_eval.(eval_name).all_num_sp_selected(:, 3:5)-all_eval.(eval_name).greedy_it_num_sp_selected;
    fprintf('====== %s =======\n', all_eval.(eval_name).name)
    fprintf('Mean improvement gco = %g, gcss = %g, gsss = %g\n', nanmean(diffsp, 1));
    fprintf('Max improvement gco = %d, gcss = %d, gsss = %d\n', nanmax(diffsp, [], 1));
%     fprintf('=== Mean Diff before Greedy ===\n');
    fprintf('Mean diff before gco - gcss = %d, gcss - gsss  = %g, gco - gsss = %g\n', -mean(diff(gsp, 1, 2)),  -mean(diff(gsp(:, [1,3]),1,2)));
%     fprintf('=== Mean Diff after Greedy ===\n');
    fprintf('Mean diff after gco - gcss = %d, gcss - gsss  = %g, gco - gsss = %g\n', -mean(diff(gitsp, 1, 2)), -mean(diff(gitsp(:, [1,3]),1,2)));

end