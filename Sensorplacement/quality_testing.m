function quality_sc_selected(


dis = input{1}.discretization;
qual = input{1}.quality;
sc_sel = input{1}.solution.sc_selected;
[~,sc_ids] = intersect(dis.sc, sc_sel, 'rows');
%%
wpn_sc = cell(1, dis.num_positions);
for idwpn = 1:dis.num_positions
    wpn_sc{idwpn} = find(dis.sc_wpn(:, idwpn));
end
qval = qual.wss.val;
%%
sc_qual = cell(1, dis.num_positions);
for idwpn = 1:dis.num_positions
   [~, id_qual] = intersect(wpn_sc{idwpn}, sc_ids);
   sc_qual{idwpn} = qval{idwpn}(id_qual);
end

allq = cell2mat(sc_qual');

%%
% sum_comb = zeros(1, dis.num_sensors);
% for idsp = 1:dis.num_sensors
    sum_comb = arrayfun(@(i) sum(dis.sc(:)==i), 1:dis.num_sensors);
    m_sc = max(sum_comb);
    (m_sc^2-m_sc)/2
    
    %%
    sc_sc = false(dis.num_sensors);
    for idsc = 1:dis.num_comb
        sc_sc(dis.sc(idsc,1), dis.sc(idsc,2)) = true;
        sc_sc(dis.sc(idsc,2), dis.sc(idsc,1)) = true;
    end