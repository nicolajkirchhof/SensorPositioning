function sc_min_quality(discretization, quality, config )
%MSPQM The minimum sensor pairwise quality model
import Optimization.Discrete.Models.write
% if config.st.enable
    %% write constraints
    %%% for every workspace point there must be one combination with a sufficient quality
    %
    %              s1s2 s1s3 ...   sNsM
    % wp1:  1 <= [   1       ...     1   ] <= inf
    % constraint is a addition of all sensorcombinations that see wp1 with sufficient quality
    % solution worst case is: 2*opt
    fid = config.filehandles.st;
    %%
    loop_display(discretization.num_positions, 10);
    write_log(' writing minimum quality constraints...');
    for idw = 1:discretization.num_positions
        %%
        wp_comb_ind = find(discretization.sc_wpn(:, idw));
        qvals = quality.wss.val{idw};
        wp_comb_flt = (qvals > config.quality.min);
        num_pairs = 1;
        if isempty(wp_comb_flt)
            error('model not solveable');
        end
        %% no sensor has quality, relax model
        if ~any(wp_comb_flt) && config.is_relax
            warning('\n relaxing model for point %d\n', idw);
            idrelax = 1;
            is_relaxed = false;
            while ~is_relaxed
                wp_comb_flt = (qvals > config.quality.min/idrelax);
                if sum(wp_comb_flt) > idrelax
                    num_pairs = idrelax;
                    write_log('\nmodel for point %d was sucessful relaxed to %d\n\n', idw, idrelax);
                    is_relaxed = true;
%                     break;
                elseif idrelax >= sum(qvals>0)
                    warning('\nmodel for point %d was not sucessful relaxed and set to %d\n\n', idw, idrelax);
                    idrelax = sum(wp_comb_flt);
                    is_relaxed = true;
                else
                    idrelax = idrelax + 1;
                end
            end
%             if num_pairs == 1
%                 warning('workspace point relaxed to max, min quality not guaranteed');
%                 num_pairs = numel(wp_comb_flt);
%                 wp_comb_flt = qvals>0;
%             end
        end
        wp_comb_ind = wp_comb_ind(wp_comb_flt);
        %%
        c_cnt = fprintf(fid, ' w%d_comb:', idw);
        write.tag_value_lines(fid, ' +s%ds%d', discretization.sc(wp_comb_ind,:), config.common.linesize, c_cnt, false);
        fprintf(fid, ' >= %d\n', num_pairs);
        if mod(idw,discretization.num_positions/100)<1
            loop_display(idw);
        end
    end
    write_log('...done ');
% end
return;
%% TEST

clear variables;
format long;
filename = 'res\floorplans\P1-Seminarraum.dxf';
config_discretization = Configurations.Discretization.iterative;

environment = Environment.load(filename);
Environment.draw(environment);
% options = config.workspace;

config_discretization.positions.additional = 0;
config_discretization.sensorspace.poses.additional = 0;

discretization = Discretization.generate(environment, config_discretization);

config_quality = Configurations.Quality.diss;
[quality] = Quality.generate(discretization, config_quality); 

config = Configurations.Optimization.Discrete.mspqm;
config.name = 'P1';
% config.

Optimization.Discrete.Models.Constraints.sc_min_quality(discretization, quality, config);
%%
cplex = 'C:\Users\Nico\App\Cplex\cplex\bin\x64_win64\cplex.exe'
solfile = Optimization.Discrete.Solver.cplex.startext(filename, cplex);
sol = Optimization.Discrete.Solver.cplex.read_solution_it(solfile);
