function [ solution ] = gsss( discretization, quality, solution, config )
%% [ solution ] = gsco( discretization, quality, config ) 
% uses the greedy single sensor selection strategy to calculate a min
% quality two coverage based on an initial workspace coverage




is_wpn_covered = false(1, discretization.num_positions);
% sensors_selected = [];
sc_selected = [];
sc_wpn_minq = uint8(zeros(discretization.num_comb, discretization.num_positions));
% qmin = config.quality.min;


%%% min quality sc_wpn_minq 
for idw = 1:discretization.num_positions
    ids = discretization.sc_wpn(:,idw)>0;
    wp_comb_flt = quality.wss.val{idw}>=config.quality.min;
    num_pairs = 1;
    %% no sensor has quality, relax model
    if sum(wp_comb_flt) == 0 %&& config.is_relax
        warning('\n relaxing model for point %d\n', idw);
        for num_pairs = [2, 4, 8]
            wp_comb_flt = (quality.wss.val{idw} >= config.quality.min/num_pairs);
            if sum(wp_comb_flt) > num_pairs
                write_log('\nmodel for point %d was sucessful relaxed to %d\n', idw, num_pairs);
                break;
            end
        end
        if num_pairs == 1
            error('workspace point relaxed to max, min quality not guaranteed');
%             num_pairs = numel(wp_comb_flt);
%             wp_comb_flt = >0;
        end
    end

    sc_wpn_minq(ids, idw) = uint8(wp_comb_flt*num_pairs);
end


%%%
wpn_remaining = double(max(sc_wpn_minq, [], 1));
%%
while any(wpn_remaining > 0)
%%
    sumq = sum(sc_wpn_minq, 2);
    [maxq maxq_id] = max(sumq);
    sc_selected = [sc_selected, maxq_id];
    wpn_ids = sc_wpn_minq(maxq_id, :)>0;
    sc_wpn_minq(maxq_id, :) = 0;
    sc_wpn_minq(:, wpn_ids) = sc_wpn_minq(:, wpn_ids)-1;
    wpn_remaining = wpn_remaining - wpn_ids;
%     num_wpn_covered = num_wpn_covered + sum(wpn_ids);
end


%% return result in solution form
sensors_selected = unique(discretization.sc(sc_selected, :));
solution = [];
solution.x = sensors_selected;
% mb.drawPoint

return;
%% TEST
clear variables;
format long;
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
fun_solve = @(filename) Optimization.Discrete.Solver.cplex.startext(filename, cplex);
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment, false);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality); 

filenames = [];

config_models = [];
modelnames = Configurations.Optimization.Discrete.get_types();

%%
% mname = modelnames.gsco;
config = Configurations.Optimization.Discrete.gsco;
% config = Configurations.Optimization.Discrete.stcm;
config.name = 'P1';
%%
solution = Optimization.Discrete.Greedy.gsco(discretization, quality, config);
hold on;
mb.drawPoint(discretization.sp(1:2,solution.x)); 
mb.drawPolygon(discretization.vfovs(solution.x));


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

