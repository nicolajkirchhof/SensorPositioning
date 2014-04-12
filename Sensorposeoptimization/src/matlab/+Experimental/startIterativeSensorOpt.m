% offset = 0;
debug_level = 0;
if offset == 0
S = Experimental.initIterativeSensorOptimization(syscal_config);
end
start = 1497;
for i = start+offset:1600; 
    disp([num2str(i) ' tes Frame, ' num2str(i-start) ' te Iteration.']);
    S(2+i-start) = Experimental.IterativeSensorOptimization(aoas(:, i),S(1+i-start), debug_level); 
    for idx_s = 1:8
        aoa_sbounds(2*idx_s-1, 1+i-start) = S(1+i-start).sensorAoaBounds{idx_s}(1); 
        aoa_sbounds(2*idx_s, 1+i-start) = S(1+i-start).sensorAoaBounds{idx_s}(2);
    end
    offset= offset+1;
end
waterfall(aoa_sbounds');