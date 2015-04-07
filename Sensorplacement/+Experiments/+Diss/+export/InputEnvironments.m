eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
wpn_initial = [];
num_sp_wpn = [0 100 200 500];
id_sp_wpn = [1 2 3 4];
[num_sp, num_wpn] = meshgrid(num_sp_wpn, num_sp_wpn);
[id_sp, id_wpn] = meshgrid(id_sp_wpn, id_sp_wpn);
num_wpn = num_wpn(:);
num_sp = num_sp(:);
id_sp = id_sp(:);
id_wpn = id_wpn(:);
diss_folder = '../../Dissertation/Thesis/tables/';
%%%
spn = nan(max(id_sp), max(id_wpn)); % line 1: 0 SP, line 2: 200 SP, line 3: 500 SP
min_dist_wpn = nan(4,4);
max_dist_wpn = nan(4,4);
num_min_dist_wpn = nan(4,4);
num_max_dist_wpn = nan(4,4);
mean_max_dist_wpn = nan(4,4);
area_environment = nan(1,4);
sc_wpn_comb = nan(3, 4);
num_nonempty_parts = nan(4,4);
wpn_nonempty_parts = cell(4, 4);
%%
for ide = 2:numel(eval_names)
    eval_name = eval_names{ide};
    
%     input = Experiments.Diss.(eval_name)(0, 0);
%     sc_wpn_comb(1, ide) = sum(input.discretization.sc_wpn(:));
    
%         input = Experiments.Diss.(eval_name)(200, 200);
%     sc_wpn_comb(2, ide) = sum(input.discretization.sc_wpn(:));
    
%         input = Experiments.Diss.(eval_name)(500, 500);
%     sc_wpn_comb(3, ide) = sum(input.discretization.sc_wpn(:));
%     continue;
    
    input = Experiments.Diss.(eval_name)(0, 0);
    wpn_initial(ide) = input.discretization.num_positions;
    wpn = double(input.discretization.wpn);
    dp = distancePoints(wpn', wpn(:,2:end)');
    min_dist_wpn(1, ide) = min(dp(dp>0));
    dp(dp==0) = inf;
    max_dist_wpn(1, ide) = max(min(dp, [], 2));
    num_min_dist_wpn(1, ide) = sum(min(dp, [], 2)==min_dist_wpn(1, ide));
    num_max_dist_wpn(1, ide) = sum(min(dp, [], 2)==max_dist_wpn(1, ide));
    num_mean_dist_wpn(1, ide) = mean(min(dp, [], 2));
    if ide > 1
        flt_parts = cellfun(@(x)x.discretization.num_positions>0, input.parts);
        num_nonempty_parts(1, ide) = sum(flt_parts);
        wpn_nonempty_parts{1, ide} = cellfun(@(x)x.discretization.num_positions, input.parts);
    end
    [~, area_environment(ide)] = bpolyclip(input.environment.combined, input.environment.combined);
    
    input = Experiments.Diss.(eval_name)(0, 100);
    wpn = double(input.discretization.wpn);
    dp = distancePoints(wpn', wpn(:,2:end)');
    min_dist_wpn(2, ide) = min(dp(dp>0));
    dp(dp==0) = inf;
    max_dist_wpn(2, ide) = max(min(dp, [], 2));
    num_min_dist_wpn(2, ide) = sum(min(dp, [], 2)==min_dist_wpn(2, ide));
    num_max_dist_wpn(2, ide) = sum(min(dp, [], 2)==max_dist_wpn(2, ide));
    num_mean_dist_wpn(2, ide) = mean(min(dp, [], 2));
    if ide > 1
    flt_parts = cellfun(@(x)x.discretization.num_positions>0, input.parts);
        num_nonempty_parts(2, ide) = sum(flt_parts);
        wpn_nonempty_parts{2, ide} = cellfun(@(x)x.discretization.num_positions, input.parts);
    end
    [~, area_environment(ide)] = bpolyclip(input.environment.combined, input.environment.combined);
    
    input = Experiments.Diss.(eval_name)(0, 200);
    wpn = double(input.discretization.wpn);
    dp = distancePoints(wpn', wpn(:,2:end)');
    min_dist_wpn(3, ide) = min(dp(dp>0));
    dp(dp==0) = inf;
    max_dist_wpn(3, ide) = max(min(dp, [], 2));
    num_min_dist_wpn(3, ide) = sum(min(dp, [], 2)==min_dist_wpn(3, ide));
    num_max_dist_wpn(3, ide) = sum(min(dp, [], 2)==max_dist_wpn(3, ide));
    num_mean_dist_wpn(3, ide) = mean(min(dp, [], 2));
    if ide > 1
    flt_parts = cellfun(@(x)x.discretization.num_positions>0, input.parts);
        num_nonempty_parts(3, ide) = sum(flt_parts);
        wpn_nonempty_parts{3, ide} = cellfun(@(x)x.discretization.num_positions, input.parts);
    end
    [~, area_environment(ide)] = bpolyclip(input.environment.combined, input.environment.combined);
    
    input = Experiments.Diss.(eval_name)(0, 500);
    wpn = double(input.discretization.wpn);
    dp = distancePoints(wpn', wpn(:,2:end)');
    min_dist_wpn(4, ide) = min(dp(dp>0));
    dp(dp==0) = inf;
    max_dist_wpn(4, ide) = max(min(dp, [], 2));
    num_min_dist_wpn(4, ide) = sum(min(dp, [], 2)==min_dist_wpn(4, ide));
    num_max_dist_wpn(4, ide) = sum(min(dp, [], 2)==max_dist_wpn(4, ide));
    num_mean_dist_wpn(4, ide) = mean(min(dp, [], 2));
    if ide > 1
    flt_parts = cellfun(@(x)x.discretization.num_positions>0, input.parts);
        num_nonempty_parts(4, ide) = sum(flt_parts);
        wpn_nonempty_parts{4, ide} = cellfun(@(x)x.discretization.num_positions, input.parts);
    end
    [~, area_environment(ide)] = bpolyclip(input.environment.combined, input.environment.combined);
    
    %     for idenv = 1:numel(num_wpn)
    %         input = Experiments.Diss.(eval_name)(num_sp(idenv), num_wpn(idenv));
    %         spn(id_sp(idenv), id_wpn(idenv)) = input.discretization.num_sensors;
    %     end
    %     spn = [nan(1, 4); spn];
    %     filename = [diss_folder eval_name '_spns.csv'];
    %     csvwrite(filename, spn);
    %     storep = [num2str(nan(1)) sprintf(',%d', nan(1,3))];
    %     find_and_replace(filename, storep, 'sp0,sp100,sp200,sp500');
end
fprintf('%g ', area_environment/1e6);
csvwrite('num_mean_dist_wpn.csv', num_mean_dist_wpn);

% fprintf('%d ', wpn_initial);

%%
figure;
cnt = 1;
for ide = 2:4
    for idd = 1:4
        subplot(3,4, cnt);
        curr = wpn_nonempty_parts{idd,ide};
        curr_sort = sort(curr(curr>0), 'descend');
%         bar(curr_sort);
%         plot((1:numel(curr_sort))/numel(curr_sort), cumsum(curr_sort)/sum(curr_sort));
        plot(cumsum(curr_sort)/sum(curr_sort));
        title(sprintf('ide = %d, idd = %d', ide, idd));
        cnt = cnt + 1;
        
    end
end
