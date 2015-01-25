function [ parts ] = filter( input, P_c )
%FILTER Summary of this function goes here
%   Detailed explanation goes here

P_c = cellfun(@(x) mb.visilibity2boost(x), P_c, 'uniformoutput', false);

flt_inpoly_cell = cellfun(@(x) binpolygon(input.discretization.wpn, x), P_c, 'uniformoutput', false);

parts = cell(numel(flt_inpoly_cell), 1);
qval_min = 0.45;

for idip = 1:numel(flt_inpoly_cell)
    part_tmp = input;
    
%     wpn_ids_excl = find(~flt_inpoly_cell{idip});
    wpn_ids_in = find(flt_inpoly_cell{idip});
    part_tmp.discretization.wpn_ids_mapping = wpn_ids_in;
    
    part_tmp.discretization.wpn = part_tmp.discretization.wpn(:, wpn_ids_in);
    part_tmp.discretization.vm = part_tmp.discretization.vm(:, wpn_ids_in);
    part_tmp.discretization.sc_wpn = part_tmp.discretization.sc_wpn(:, wpn_ids_in);
    part_tmp.discretization.num_positions = numel(wpn_ids_in);
    
    part_tmp.quality.wss.val = part_tmp.quality.wss.val(wpn_ids_in);
    
    %%%
    ids_sc = [];
    for idwpn = 1:part_tmp.discretization.num_positions
        ids_sc_add = find(part_tmp.discretization.sc_wpn(:, idwpn));
        flt_qual = part_tmp.quality.wss.val{idwpn}>qval_min;
        ids_sc = unique([ids_sc_add(flt_qual); ids_sc]);
    end
    %%%
    ids_sensors = part_tmp.discretization.sc(ids_sc, :);
    ids_sensors = unique(ids_sensors(:));
%     ids_sensors_out = setdiff(1:part_tmp.discretization.num_sensors, ids_sensors);
    part_tmp.discretization.sp_ids_mapping = ids_sensors;
    part_tmp.discretization.num_sensors = numel(ids_sensors);
    part_tmp.discretization.spo = part_tmp.discretization.spo(ids_sensors, ids_sensors);
    part_tmp.discretization.sp = part_tmp.discretization.sp(:, ids_sensors);
    part_tmp.discretization.vm = part_tmp.discretization.vm(ids_sensors, :);
    part_tmp.discretization.vfovs = part_tmp.discretization.vfovs(ids_sensors);

    spo_ids = cellfun(@(x) intersect(ids_sensors, x), part_tmp.discretization.spo_ids, 'uniformoutput', false);
    flt_spo = cellfun(@(x) ~isempty(x), spo_ids);
    spo_ids = spo_ids(flt_spo);
    part_tmp.discretization.spo_ids = cellfun(@(x) changem(x, 1:numel(ids_sensors), ids_sensors), spo_ids, 'uniformoutput', false);
    
    part_tmp.discretization.sc_ids_mapping = ids_sc;
    sc = part_tmp.discretization.sc(ids_sc, :);
    part_tmp.discretization.sc = changem(sc, 1:numel(ids_sensors), ids_sensors);
    
    
    part_tmp.discretization.sc_wpn = part_tmp.discretization.sc_wpn(ids_sc, :);
    part_tmp.discretization.num_comb = numel(ids_sc);
    
    part_tmp.quality = Quality.WSS.kirchhof(part_tmp.discretization, part_tmp.config.quality);
    
    parts{idip} = part_tmp;
end

end

