clearvars -except all_eval*

%%% conference room
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
name = 'conference_room';

opt_names = {'cmqm_nonlin_it', 'cmqm_cmaes_it' 'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd'};

diss_folder = '../../Dissertation/Thesis/tables/';
% opt_name= opt_names{1};
%%%
    [X, Y] = meshgrid(0:10:500, 0:10:500);
    range = 1:10:51;
    [idx, idy] = meshgrid(range, range);
    ind = sub2ind([51 51], idx(:), idy(:));
    

%%
for idn = 1:numel(eval_names)
    eval_name= eval_names{idn};
            [ids, idwpn] = ind2sub([51, 51], ind);
        num_sp = 10*(ids(:)-1);
        num_wpn = 10*(idwpn(:)-1);
        all_wpn = zeros(size(num_wpn));
        all_sp = zeros(size(num_sp));
    for idnsp = 1:numel(num_sp)
        input = Experiments.Diss.(eval_name)(num_sp(idnsp), num_wpn(idnsp));
        all_wpn(idnsp) = input.discretization.num_positions;
        all_sp(idnsp) = input.discretization.num_sensors;
    end
    table_names = {'all_num_sp_selected', 'all_mean_wpn_qualities', 'all_area_covered_pct'};
    %%
    for idt = 1:numel(table_names)
        table_name = table_names{idt};
        
        mat = all_eval.(eval_name).(table_name);
        mat = round(mat(ind, :)*100)/100;

        mat = [num_sp num_wpn all_sp(:) all_wpn(:) mat];
        header = -1*ones(1, size(mat, 2));
        mat = [header; mat];
        filename = [diss_folder eval_name '_' table_name '.csv'];
        csvwrite(filename, mat);
        find_and_replace(filename,'NaN', '---');
        storep = [num2str(header(1)) sprintf(',%d', header(2:end))];
        find_and_replace(filename, storep, 'ids,idw,nas,naw,cmqmnonlinit,cmqmcmaesit,gco,gcss,gsss,stcm,mspqm,bspqm,mspqmrpd,bspqmrpd');
        
    end
end
