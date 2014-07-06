function tekdas( discretization, quality, config )
%ADD_COMBINATIONS Summary of this function goes here
%   Detailed explanation goes here
%% write constraints
%%% first part of and constrints
% -si2 + di1i2 <= 0
% two values per row and two equations
%  si_dij_lhs >= [si_dij_i, si_dij_j(l,r)]   <= si_dij_rhs
%                 Si1 ... Si2 .... di1i2
%  -inf       <= [ -1               1   ] <= 0
%  -inf       <= [        -1        1   ] <= 0
%%% second part of and constraints
% si1 si2 - di1i2 <= 1
% matrix representations has the form
% sij_dij_lhs <=[sij_dij_i,[discretization.sc_idx, sij_dij_j]]<= sij_dij_rhs
%                 Si1 ... Si2 .... di1i2
%  -inf        <= [ 1      1        -1   ] <= 1
import Optimization.Discrete.Models.write
fid = config.filehandles.st;
bfid = config.filehandles.bin;
%%
loop_display(discretization.num_comb, 10);
write_log(' writing constraints...');
for idp = 1:discretization.num_positions
   wp_comb_ind = find(discretization.sc_wpn(:, idp));
   qvals = quality.wss.val{idp};
   wp_comb_flt = (qvals > config.quality.min);
%    num_pairs = 1;
%     num_pairs = 1;
    if ~any(wp_comb_flt) && config.is_relax
            warning('\n relaxing model for point %d\n', idp);
            idrelax = 1;
            is_relaxed = false;
            while ~is_relaxed
                wp_comb_flt = (qvals > config.quality.min/idrelax);
                if sum(wp_comb_flt) > idrelax
                    write_log('\nmodel for point %d was sucessful relaxed to %d\n\n', idp, idrelax);
                    is_relaxed = true;
                else
                    idrelax = idrelax + 1;
                end
            end
    end
%    if sum(wp_comb_flt) < 1
%         [maxq id_maxq] = max(qvals);
%         warning('model relaxed at wpn %d to %e', idp, maxq);
%         wp_comb_flt(id_maxq) = 1;
%         error('model not solveable');
%    end
    
    fltwp = logical(discretization.sc_wpn(:,idp));
    % set all comb that do not fulfill the quality to zero
    fltwp(wp_comb_ind(~wp_comb_flt)) = 0;
    for idc = find(fltwp)'
        fprintf(fid,'x%1$d_%2$d_%3$dANDs%2$d: s%2$d - x%1$d_%2$d_%3$d >= 0\n',  idp, discretization.sc(idc, 1),discretization.sc(idc, 2) );
        fprintf(fid,'x%1$d_%2$d_%3$dANDs%3$d: s%3$d - x%1$d_%2$d_%3$d >= 0\n',  idp, discretization.sc(idc, 1),discretization.sc(idc, 2) );
    end
    wp_comb = discretization.sc(fltwp,:);
    ids_sensors = unique(discretization.sc(fltwp,:));

    fprintf(fid, 'Sumz%d:',  idp);
    wp_string = sprintf(' +z%d_%%d', idp);
    write.tag_value_lines(fid, wp_string, ids_sensors, config.common.linesize);
    fprintf(fid, ' = 2\n');
    %% write binaries
    wp_string = sprintf(' z%d_%%d', idp);
    write.tag_value_lines(bfid, wp_string, ids_sensors, config.common.linesize);
    wp_string = sprintf(' x%d_%%d_%%d', idp);
    write.tag_2value_lines(bfid, wp_string, wp_comb(:,1), wp_comb(:,2), config.common.linesize);

    %%
    for ids = ids_sensors(:)'
        flt_wp_comb = wp_comb(:,1)==ids|wp_comb(:,2)==ids;
        fprintf(fid,'Sum_z%d_%d:',  idp, ids);
        wp_string= sprintf(' +x%d_%%d_%%d', idp);
        write.tag_2value_lines(fid, wp_string, wp_comb(flt_wp_comb,1), wp_comb(flt_wp_comb,2), config.common.linesize);
        fprintf(fid,' - z%d_%d = 0\n', idp, ids);    
    end
    
end

write_log('...done ');
return;
%% Tests
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

config = Configurations.Optimization.Discrete.tekdas;
%%
Optimization.Discrete.Models.Constraints.tekdas(discretization, quality, config);

