%%
clearvars -except all_eval*;
% clearvars -except small_flat conference_room large_flat office_floor
%%%
eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
outdir_tables = '..\..\Dissertation\thesis\tables\';
%%%
% for ideval = 1:4
%%%
for ideval = 3:4 %:numel(eval_names)
    %%
    close all;
%     ideval = 3;
    eval_name = eval_names{ideval};
    
    [X, Y] = meshgrid(0:10:500, 0:10:500);
    range = 1:10:21;
    [idx, idy] = meshgrid(range, range);
    idx = idx(:);
    idy = idy(:);
    ind = sub2ind([51 51], idx(:), idy(:));
    
    xlist = X(ind);
    ylist = Y(ind);
    
    all_x = unique(xlist);
    all_y = unique(ylist);
    %%%
    opt_names = {'gco', 'gcss', 'gsss', 'stcm', 'mspqm', 'bspqm', 'mspqm_rpd', 'bspqm_rpd'};
    
    for idon = 1:numel(opt_names)
        %%
        opt_name = opt_names{idon};
        if ~(isfield(all_eval.(eval_name), opt_name))
            continue;
        end
        %%
        idn_created = [];
        include_strings = {};
        include_values = {};
        for idopt = 1:numel(xlist);
            %%
            opts = all_eval.(eval_name).(opt_name);
            if ~(size(opts,1) >= idx(idopt) && size(opts, 2) >= idy(idopt))
                continue;
            end
            opt_sol = opts{idx(idopt), idy(idopt)};
            if isempty(opt_sol)
                continue;
            end
            num_sp = opt_sol.num_sp;
            num_wpn = opt_sol.num_wpn;
            input = Experiments.Diss.(eval_name)(num_sp, num_wpn);
            solution = Evaluation.filter(opt_sol, input.discretization, Configurations.Quality.diss);
            environment = input.environment;
            idn_created = [idn_created idopt];
            if isfield(environment, 'P_c')
                P_c = environment.P_c;
            else
                P_c = {};
            end
            
            if isfield(environment, 'E_r')
                E_r = environment.E_r;
            else
                E_r = {};
            end
            bpoly = environment.combined;
            %%%
            cla
            hold on
            set(gcf, 'color', 'w')
            if ideval == 4
                sm = 2;
            elseif ideval == 3
                sm = 3;
            else
                sm = 4;
            end
            Environment.draw(input.environment, false);
            mb.drawPolygon(environment.occupied, 'color', [0.6, 0.6, 0.6]);
            fun_draw_edge = @(e) drawEdge(e, 'linewidth', 0.7, 'linestyle', ':', 'color', [0 0 0]);
            cellfun(@(x) fun_draw_edge(x.edge), E_r);
            mb.drawPolygon(bpoly, 'color', [0 0 0], 'linewidth', 1);
            mb.drawPoint(input.discretization.wpn, 'marker', '.', 'color', 0*ones(1,3), 'markersize', sm);
            
            base_sp_mid = solution.sp;
            base_sp_mid(3, :) = base_sp_mid(3, :) + deg2rad(input.config.discretization.sensor.fov/2);
            if ideval == 4
                mb.drawPose(base_sp_mid, 1000, 'color', 0*ones(1,3), 'linewidth', 0.5, 'markersize', sm, 'markerfacecolor', 'w');
                mb.drawPoint(input.discretization.sp(1:2,:), 'marker', 'o', 'color', 0.8*ones(1,3), 'markersize', sm/2, 'linewidth', 0.5);
            elseif ideval == 3
                mb.drawPose(base_sp_mid, 800, 'color', 0*ones(1,3), 'linewidth', 0.75, 'markersize', sm, 'markerfacecolor', 'w');
                mb.drawPoint(input.discretization.sp(1:2,:), 'marker', 'o', 'color', 0.8*ones(1,3), 'markersize', sm/2, 'linewidth', 0.75);
            else
                mb.drawPose(base_sp_mid, 600, 'color', 0*ones(1,3), 'linewidth', 1.5, 'markersize', sm, 'markerfacecolor', 'w');
                mb.drawPoint(input.discretization.sp(1:2,:), 'marker', 'o', 'color', 0.8*ones(1,3), 'markersize', sm/2, 'linewidth', 1.5);
            end
            for idv = 1:numel(solution.vfovs)
                mb.fillPolygon(solution.vfovs{idv}, 'k', 'facealpha', 0.1);
            end
            
            % title(sprintf('SP = %d, WPN = %d', num_sp, num_wpn));
            axis off;
            %%%
            axis equal
            filename = sprintf('%s_%s_%d_%d.tex', eval_name, opt_name, num_sp, num_wpn);
            full_filename = sprintf('export/%s', filename);
            matlab2tikz(full_filename, 'parseStrings', false,...
                ...         'height', '8cm',...
                'width', '5cm',...
                'extraCode', '\standaloneconfig{border=0.1cm}',...
                'standalone', true);
            
            % Figures.compilePdflatex(filename, true, true);
            Figures.compilePdflatex(filename, true, false, 'Appendix/');
%                                 Figures.compilePdflatex(filename, false);
            % pause;
            if any(ideval == [3 4])
                include_strings{end+1} = sprintf('\\includegraphics{Figures/Appendix/%s_%s_%d_%d.pdf}', eval_name, opt_name, num_sp, num_wpn);
            else
                include_strings{end+1} = sprintf('\\includegraphics[angle=90]{Figures/Appendix/%s_%s_%d_%d.pdf}', eval_name, opt_name, num_sp, num_wpn);
            end
            include_values{end+1} = sprintf('$(%d, %d, %d, %d, %d\\%%, %d\\%%)$', num_sp, num_wpn,...
                input.discretization.num_sensors, solution.num_sensors, ...
                round(100*opt_sol.quality.sum_max/input.discretization.num_positions), round(opt_sol.quality.area_covered));
        end
        %%
        latex_filename = [eval_name '_' opt_name '_placements.tex'];
        fid = fopen(latex_filename, 'w');
        tablerow = '%s & %s \\\\\n';
        fprintf(fid, '\\begin{longtable}{C{6cm} C{6cm}}');
        for idc = 1:2:numel(idn_created)-1
            %%
            fprintf(fid, tablerow, include_strings{idc}, include_strings{idc+1});
            fprintf(fid, tablerow, include_values{idc}, include_values{idc+1});
        end
        
        if idc < numel(idn_created)-1
            fprintf(fid, tablerow, include_strings{idc}, include_strings{end});
            fprintf(fid, tablerow, include_values{idc}, include_values{end});
        end
        fprintf(fid, '\\end{longtable}');
        fclose(fid);
        movefile(latex_filename, [outdir_tables latex_filename]);
        
    end
end
