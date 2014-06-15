function [  ] = mspqm(discretization, config  )
%MSPQM The minimum sensor pairwise quality model

[model_path, model_name] = fileparts(mfilename('fullpath'));
model_prefix = model_path(max(strfind(model_path, '+'))+1:end);
model_type = [model_prefix '_' model_name];
%%
% if .progress.model.(model_type)
%      = model.enable(, model_type);
%     return;
% end
% if ~.progress.model.sameplace
%      = model.add.sameplace();
% end
% qname = .model.(model_type).quality.name;
% if ~.progress.quality.(qname)
%      = .quality.(qname).fct(, .model.(model_type).quality.param);
% end


[] = model.init(, model_type);

%%
write_log(' writing %s model', model_type);
%% write objective values
fid = .model.(model_type).obj.fid;
%%
% if .model.(model_type).obj.enable
    loop_display(.problem.num_comb, 10);
    write_log(' writing obj function...');
    model.write.tag_value_lines(fid, ' +s%ds%d', .problem.sc_idx, .common.linesize);
    write_log('...done ');
% end

% if .model.(model_type).st.enable
    %% write constraints
    %%% for every workspace point there must be one combination with a sufficient quality
    %
    %              s1s2 s1s3 ...   sNsM
    % wp1:  1 <= [   1       ...     1   ] <= inf
    % constraint is a addition of all sensorcombinations that see wp1 with sufficient quality
    % solution worst case is: 2*opt
    fid = .model.(model_type).st.fid;
    %%
    loop_display(.problem.num_positions, 10);
    write_log(' writing constraints...');
    for idw = 1:.problem.num_positions
        %%
        wp_comb_ind = find(.problem.wp_sc_idx(:, idw));
        qvals = .quality.(.model.(model_type).quality.name).val{idw};
        wp_comb_flt = (qvals > .model.(model_type).quality.min);
        num_pairs = 1;
        if isempty(wp_comb_flt)
            error('model not solveable');
        end
        %% no sensor has quality, relax model
        if ~any(wp_comb_flt)
            write_log('relaxing model for point %d', idw);
            for idrelax = [1, 2, 4, 8]
                wp_comb_flt = (qvals > .model.(model_type).quality.min/idrelax);
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
        model.write.tag_value_lines(fid, ' +s%ds%d', .problem.sc_idx(wp_comb_ind,:), .common.linesize, c_cnt, false);
        fprintf(fid, ' >= %d\n', num_pairs);
        if mod(idw,.problem.num_positions/100)<1
            loop_display(idw);
        end
    end
    write_log('...done ');
% end
% if .model.(model_type).bin.enable
    %% write Binaries
    fid = .model.(model_type).bin.fid;
    %%
    loop_display(.problem.num_comb, 10);
    write_log(' writing binaries...');
    model.write.tag_value_lines(fid, ' s%ds%d', .problem.sc_idx, .common.linesize);
    write_log('...done ');
    %%
% end
     = model.finish(,model_type);
    write_log('... done ');
return;
%% testing
close all; clearvars all; fclose all;
clear all;
%%
 = processing_configuration('sides4_nr0');
.environment.file = 'res/env/convex_polygons/sides4_nr0.environment';
.sensorspace.uniform_position_distance = 100*5;
.sensorspace.uniform_angle_distance = deg2rad(45/2);
.workspace.grid_position_distance = 100*5;
.sensors.distance.min = 0;
.sensors.distance.max = 6000;
.model.wss_qclip.quality.min = 0.5;
% .model.wss_qclip.quality.name = .quality.types.wss_dirdist;
% .model.wss_qclip.quality.name = .quality.types.wss_distgeom;
.model.wss_qclip.quality.name = .quality.types.wss_dd_dop;
.model.wss_qclip.quality.param = 2;
% .model.wss_qclip.obj.enable = false;
% .model.wss_qclip.bin.enable = false;
%  = model.ws.coverage();
%  = model.wss.sc_backward();
%  = model.wss.sensorcomb();
 = model.wss.qclip();
%%%
 = model.save();
%%
cpx = solver.cplex.startext(.model.lastsave);
if ~isempty(cpx)
     draw.ws_solution(, cpx);
%     draw.ws_solution(, cpx.Solution);
%     draw.wss_wp_solution(, cpx.Solution);
%     draw.ws_wp_solstats(, cpx.Solution);

end
%%%
%%%
