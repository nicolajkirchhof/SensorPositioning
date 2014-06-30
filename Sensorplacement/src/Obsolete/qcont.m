function [ pc ] = qcont( pc )
%DIRECTIONAL_2COMB Uses the sensorcombinations to state the optimization problem

[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
model_type = [model_prefix '_' model_name];
%%
if pc.progress.model.(model_type)
    pc = model.enable(pc, model_type);
    return;
end
% if ~pc.progress.model.sameplace
%     pc = model.add.sameplace(pc);
% end
qname = pc.model.(model_type).quality.name;
if ~pc.progress.quality.(qname)
    pc = pc.quality.(qname).fct(pc, pc.model.(model_type).quality.param);
end


[pc] = model.init(pc, model_type);

%%
write_log(' writing %s model', model_type);
%% write objective values
fid = pc.model.(model_type).obj.fid;
%%
% if pc.model.(model_type).obj.enable
    loop_display(pc.problem.num_comb, 10);
    write_log(' writing obj function...');
    model.write.tag_value_lines(fid, ' +s%ds%d', pc.problem.sc_idx, pc.common.linesize);
    write_log('...done ');
% end

% if pc.model.(model_type).st.enable
    %% write constraints
    %%% for every workspace point there must be one combination with a sufficient quality
    %
    %              s1s2 s1s3 ...   sNsM
    % wp1:  1 <= [   1       ...     1   ] <= inf
    % constraint is a addition of all sensorcombinations that see wp1 with sufficient quality
    % solution worst case is: 2*opt
    fid = pc.model.(model_type).st.fid;
    %%
    loop_display(pc.problem.num_positions, 10);
    write_log(' writing constraints...');
    for idw = 1:pc.problem.num_positions
        %%
        wp_comb_ind = find(pc.problem.wp_sc_idx(:, idw));
        qvals = pc.quality.(pc.model.(model_type).quality.name).val{idw};
        wp_comb_flt = (qvals > pc.model.(model_type).quality.reject);
        num_pairs = 1;
        if isempty(wp_comb_flt)
            error('model not solveable');
        end
        %% no sensor has quality, relax model
        if ~any(wp_comb_flt)
            write_log('relaxing model for point %d', idw);
            for idrelax = [1, 2, 4, 8]
                wp_comb_flt = (qvals > pc.model.(model_type).quality.min/idrelax);
                if sum(wp_comb_flt) > idrelax
                    num_pairs = idrelax;
                    write_log('model for point %d was sucessful relaxed to %d ', idw, idrelax);
                    break;
                end
            end
            if num_pairs == 1
                warning('workspace point relaxed to max, min quality not guaranteed');
                num_pairs = numel(wp_comb_flt);
                wp_comb_flt = qvals>0;
            end
        end
        wp_comb_ind = wp_comb_ind(wp_comb_flt);
        %%
        c_cnt = fprintf(fid, ' w%d_comb:', idw);
        model.write.tag_2value_lines(fid, ' +%e s%ds%d', qvals(wp_comb_flt), pc.problem.sc_idx(wp_comb_ind,:), pc.common.linesize, c_cnt, false);
        fprintf(fid, ' >= %e\n', pc.model.(model_type).quality.min);
        if mod(idw,pc.problem.num_positions/100)<1
            loop_display(idw);
        end
    end
    write_log('...done ');
% end
% if pc.model.(model_type).bin.enable
    %% write Binaries
    fid = pc.model.(model_type).bin.fid;
    %%
    loop_display(pc.problem.num_comb, 10);
    write_log(' writing binaries...');
    model.write.tag_value_lines(fid, ' s%ds%d', pc.problem.sc_idx, pc.common.linesize);
    write_log('...done ');
    %%
% end
    pc = model.finish(pc,model_type);
    write_log('... done ');
return;
%% testing
close all; clearvars all; fclose all;
clear all;
pc = processing_configuration('sides4_nr0');
pc.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
pc.sensorspace.uniform_position_distance = 100*5;
pc.sensorspace.uniform_angle_distance = deg2rad(45/2);
pc.workspace.grid_position_distance = 100*5;
pc.sensors.distance.min = 0;
pc.sensors.distance.max = 6000;
pc.model.wss_qcont.quality.min = 0.5;
% pc.model.wss_qclip.quality.name = pc.quality.types.wss_dirdist;
% pc.model.wss_qclip.quality.name = pc.quality.types.wss_distgeom;
pc.model.wss_qcont.quality.name = pc.quality.types.wss_dd_dop;
pc.model.wss_qcont.quality.param = 2;
% pc.model.wss_qclip.obj.enable = false;
% pc.model.wss_qclip.bin.enable = false;
% pc = model.ws.coverage(pc);
% pc = model.wss.sc_backward(pc);
% pc = model.wss.sensorcomb(pc);
pc = model.wss.qcont(pc);
%%%
pc = model.save(pc);
%%
cpx = solver.cplex.startext(pc.model.lastsave);
if ~isempty(cpx)
     draw.ws_solution(pc, cpx);
%     draw.ws_solution(pc, cpx.Solution);
%     draw.wss_wp_solution(pc, cpx.Solution);
%     draw.ws_wp_solstats(pc, cpx.Solution);
    
end
%%%
