for i = 1:8
    cnt = 1;
    for j = [1,4:1:22]
        pixel_values_n{i, cnt} = pixel_values{i,j};
        pixel_values_normalized_n{i, cnt} = pixel_values_normalized{i,j};
        position_estimates_n{i, cnt} = position_estimates{i,j};
        ref_values_n(cnt, :) = ref_values(j, :);
        aoas_n{i, cnt} = aoas{i,j};
        cnt = cnt+1;
    end
end

pixel_values = pixel_values_n;
pixel_values_normalized = pixel_values_normalized_n;
position_estimates = position_estimates_n;
ref_values = ref_values_n;
aoas = aoas_n;


%% remove aoas
idx = {[2,7];[8,7];[15,7];[17,7];[19,7];[20,7]};

for i = 1:numel(idx)
    aoas{idx{i}(2), idx{i}(1)} = [];
    pixel_values_normalized{idx{i}(2), idx{i}(1)} = [];
end
    