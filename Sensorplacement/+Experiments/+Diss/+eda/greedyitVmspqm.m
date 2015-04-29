eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
opt_names = {'gco_i', 'gcss', 'gsss'};
close all;
for ideval = 1:numel(eval_names)
    %%
    %     ideval = 1;
    eval_name = eval_names{ideval};
    flt_mspqm = ~cellfun(@isempty, all_eval.(eval_name).mspqm);
    hgco = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.(eval_name).gco_it(flt_mspqm), all_eval.(eval_name).mspqm(flt_mspqm));
    hgsss = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.(eval_name).gsss_it(flt_mspqm), all_eval.(eval_name).mspqm(flt_mspqm));
    hgcss = cellfun(@(x,y) numel(x.sensors_selected)/numel(y.sensors_selected), all_eval.(eval_name).gcss_it(flt_mspqm), all_eval.(eval_name).mspqm(flt_mspqm));
    
%     cc = corrcoef([haos, hreal]);
    fprintf('%s mean gco = %g, gcss = %g, gsss = %g\n',eval_name, mean(hgco), mean(hgcss), mean(hgsss));
    ccs{ideval} = cc;
    
end