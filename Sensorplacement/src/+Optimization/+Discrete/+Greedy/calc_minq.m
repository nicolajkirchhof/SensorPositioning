function [ sc_wpn_minq ] = calc_minq( discretization  )
%RELAX_MODEL Summary of this function goes here
%   Detailed explanation goes here

%%% min quality sc_wpn_minq
for idw = 1:discretization.num_positions
    ids = discretization.sc_wpn(:,idw)>0;
    wp_comb_flt = quality.wss.val{idw}>=config.quality.min;
    num_pairs = 1;
    %% no sensor has quality, relax model
    if sum(wp_comb_flt) == 0 %&& config.is_relax
        warning('\n relaxing model for point %d\n', idw);
        num_pairs = 1;
        while is_relaxed;
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

end

