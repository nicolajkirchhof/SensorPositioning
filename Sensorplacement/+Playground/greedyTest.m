%% testing greedy opt
qmin = 0.3;
wp_sc_flt = cellfun(@(x) x>qmin, pc.quality.wss_dd_dop.val, 'uniformoutput', false);
sc_wp_idx = cell(pc.problem.num_sensors);
%%
for idwp = 1:pc.problem.num_positions
    %%
    sc_idx = find(pc.problem.wp_sc_idx(:,idwp));
    sc_idx_sel = sc_idx(wp_sc_flt{idwp});
    
    sc_ind = sub2ind(size(pc.problem.sc_ij), double(pc.problem.sc_idx(sc_idx_sel,1)),double(pc.problem.sc_idx(sc_idx_sel,2)));
    for idsc = sc_ind(:)'
        sc_wp_idx{idsc} = [sc_wp_idx{idsc} idwp];
    end
end
%%
sc_wp_num = cellfun(@numel, sc_wp_idx);
sc_wp_idx_up = sc_wp_idx;
sc_wp_rel_flt = triu(true(size(sc_wp_idx_up)), 1);

[mx, mx_ind] = max(sc_wp_num(:));
[s1_idx, s2_idx] = ind2sub(size(sc_wp_num), mx_ind);
sel_sensors = [s1_idx, s2_idx];
scale = 2;
draw.workspace(pc)
hold on;
    mb.drawPolygon(pc.problem.V(sel_sensors))
    mb.drawPoint(pc.problem.S(1:2,sel_sensors))
    %%
while mx > 0;
    %%
    sc_wp_idx_up(sc_wp_rel_flt) = cellfun(@(x) setdiff(x, sc_wp_idx_up{mx_ind}), sc_wp_idx_up(sc_wp_rel_flt), 'uniformoutput', false); 
    sc_wp_num_up = cellfun(@numel, sc_wp_idx_up);
    
   [mxc, mx_indc] = max(sc_wp_num_up(sel_sensors, :),[], 2);
   [mxr, mx_indr] = max(sc_wp_num_up(:,sel_sensors),[], 1);
   [mx_sel, mx_sel_ind] = max([mxc(:); mxr(:)]);
    [mx, mx_ind] = max(sc_wp_num_up(:));
    %%
    if mx > 0 && mx <= scale*mx_sel 
        % choose only one additional sensor if gain is less than scale times the number of added wp
        if mx_sel_ind <= numel(mxc)
            % mx_sel_ind is column
            s2_idx = mx_indc(mx_sel_ind);
            s1_idx = sel_sensors(mx_sel_ind);                       
        else
            [~, mx_sel_ind] = max(mxr);
            s1_idx = mx_indr(mx_sel_ind);
            s2_idx = sel_sensors(mx_sel_ind);           
        end
        mx_ind = sub2ind(size(sc_wp_idx_up), s1_idx, s2_idx);
    else
        [s1_idx, s2_idx] = ind2sub(size(sc_wp_num), mx_ind);    
    end
    
    %%    
    sel_sensors = unique([sel_sensors, s1_idx, s2_idx]);
    mb.drawPolygon(pc.problem.V(sel_sensors))
    mb.drawPoint(pc.problem.S(1:2,sel_sensors))
    pause
end
%%
draw.workspace(pc)
hold on;
mb.drawPolygon(pc.problem.V(sel_sensors))
mb.drawPoint(pc.problem.S(1:2,sel_sensors))
