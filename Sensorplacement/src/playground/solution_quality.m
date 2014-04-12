function pc = calculate_solution_goodness(pc)

if ~isfield(pc, 'solution') || isempty(pc.problem.Solution)
%     pc.problem.Solution.sensor_ids = find(pc.problem.Solution.x);
%     xt_ij_selected =pc.problem.xt_ij(logical(pc.problem.Solution.x),:);
% else
   error('no solution found');
end


pc = calculate_solution_goodness_coverage(pc);

num_spp = sum(pc.problem.Solution.xt_ij_selected, 1);
num_comb = sum(arrayfun(@nchoosek, full(num_spp)', ones(size(num_spp'))*2));
% q_all = cell(num_comb,1);

% Analogue to kelly with replacement 1/sin with 1-sin
% angular quality measure = max over all sensor pairs { r1*r2*(1-sin(phi) }
pc.problem.Solution.q_ang = nan(pc.problem.Solution.sensor_num, pc.workspace.number_of_positions);
% lateration quality measure = max over all sensor pairs { (1-sin(phi) }
pc.problem.Solution.q_lat = nan(pc.problem.Solution.sensor_num, pc.workspace.number_of_positions);
% distance from each sensor to each point
pc.problem.Solution.q_dist = nan(pc.problem.Solution.sensor_num, pc.workspace.number_of_positions);
% calc num of possible combinations
%%
for idw = 1:size(pc.problem.Solution.xt_ij_selected,2)
    %%
    ids = find(pc.problem.Solution.xt_ij_selected(:, idw));
    ps = pc.problem.S(1:2, ids);
    pw = pc.problem.W(:,idw);
    dist_points = distancePoints(ps', pw');
    pc.problem.Solution.q_dist(ids, idw) = dist_points;
    
    cb = combnk(ids, 2);
    
    q_ang_best = -inf;
    q_lat_best = -inf;
    idc_ang_best = nan;
    idc_lat_best = nan;
    %%
    for idc = 1:size(cb, 1)
        %%
        ps1 = pc.problem.S(1:2, cb(idc,1));
        ps2 = pc.problem.S(1:2, cb(idc,2));
        % find right angle
        ang = angle3Points(ps1',pw',ps2');
        if ang > pi
            ang = 2*pi - ang;
        end
        lat_goodness = (1-sin(ang))/2;
        r1 = distancePoints(ps1',pw');
        r2 = distancePoints(ps2',pw');
        %compensate for points on same position as sensor
        if r1==0 || r2==0
            ang_goodness = max([r1, r2])*(lat_goodness+pc.common.grid_limit);
        else
            ang_goodness = r1*r2*(lat_goodness+pc.common.grid_limit);
        end
        if q_ang_best < ang_goodness
            q_ang_best = ang_goodness;
            idc_ang_best = idc;
        end
        if q_lat_best < lat_goodness
            q_lat_best = lat_goodness;
            idc_lat_best = idc;
        end
        
    end
    %%
    pc.problem.Solution.q_ang(cb(idc_ang_best,:), idw) = q_ang_best;
    pc.problem.Solution.q_lat(cb(idc_lat_best,:), idw) = q_lat_best;
    
end

