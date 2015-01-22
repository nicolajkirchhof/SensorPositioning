function sp_qval = qscale(discretization, quality)
%%
% discretization = input{1}.discretization;
% quality = input{1}.quality;

[r, c] = find(discretization.spo);
sp_comb = [r c];
sp_qval = cell(discretization.num_sensors, 1);
%%
for idsp = 1:discretization.num_sensors
    flt_comb = any(discretization.sc==idsp, 2);
    ids_comb = find(flt_comb);
    %%
    for idw = 1:discretization.num_positions
        %%
        qvals = quality.wss.val{idw};
        sc_ids = find(discretization.sc_wpn(:, idw));
        flt_sc = ismember(sc_ids, ids_comb);
        qvals_sc_valid = qvals(flt_sc);
        sc_ids_valid = sc_ids(flt_sc);
        
        sc_valid = discretization.sc(sc_ids_valid,:);
        % set idsp to 0 to allow sort and cut
        sc_valid(sc_valid==idsp) = 0;
        sc_sort = sort(sc_valid, 2);
        s2_valid = sc_sort(:,2);
        
        %% use only one sensor of every spn
        for idspo = 1:numel(discretization.spo_ids)
            %%
            ids_intersect = intersect(s2_valid, discretization.spo_ids{idspo});
            if ~isempty(ids_intersect)
                flt_qvals = ismember(s2_valid, ids_intersect);
                qvals_s1_s2 = qvals_sc_valid(flt_qvals);
                if range(qvals_s1_s2) ~= 0
                    error('not all values are equal, investigate');
                end
                sp_qval{idsp} = [sp_qval{idsp} qvals_s1_s2(1)]; 
            end
        end              
    end
end