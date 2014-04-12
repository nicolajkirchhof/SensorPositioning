%% test multipoly insidepoly
pct = 0;
profile on;
for idx = 1:numel(wc.V)
    inmp = multipoint_insidepoly(wc.W(1:2,:), [wc.V{idx}.x'; wc.V{idx}.y']);
    inply = inpolygon(wc.W(1,:)', wc.W(2,:)', wc.V{idx}.x, wc.V{idx}.y);
    if any(inmp' ~= inply)
        figure; cla; hold on; plot(inmp, '.g'); plot(inply', 'or')
        find(inmp' ~= inply);
        error('INVESTIGATE');
    end
    if floor(idx/numel(wc.V))>pct
        pct = floor(idx/numel(wc.V));
        fprintf(1, 'idx=%d, pct=%g', idx, pct);
    end 
end
profile disp;