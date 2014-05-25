function comb = combNunique(val,k)
%% creates all unique k combinations which are
% val1 val2 ... valn
% val1 val2 ... valn+1
if size(val,2)>1
    val = val(:);
end

fun_n_comb = @(n, k) factorial(n)/(factorial(k)*factorial(n-k));
num_combinations = fun_n_comb(numel(val), k);

comb = zeros(num_combinations, k);
for idcol = 0:k-1
    el_occurences = (numel(val)-idcol)-(k-1);
    for idel = 1:numel(val)
        el_occurence(
    end
end


num_el_1 = numel(val)-1;
num_combi = num_el_1:-1:1;

idx_combi = [0 cumsum(num_combi)];
num_combs = sum(num_combi);
comb = zeros(num_combs,2);
for idc = 1:num_el_1
    idx_combs = idx_combi(idc)+1:idx_combi(idc+1);
    comb(idx_combs,1) = val(idc);
    comb(idx_combs,2) = val(idc+1:end);
end

% function [c1, c2] = create_comb(id1, id2)
% %     c1 = repmat(id1, size(val(id2:end)));
%     c1 = repmat(val(id1), [1, num_el_1-id2+1]);
%     c2 = val(id2:end)';
% end
% % fun_create_comb = @(id1, id2) [repmat(id1, size(val(id2:end))), val(id2:end)];
% % comb = cell2mat(arrayfun(fun_create_comb, val(1:end-1), (2:numel(val))', 'uniformoutput', false));
% % [c1, c2] = arrayfun(@create_comb, val(1:end-1), (2:numel(val))');
% [c1, c2] = arrayfun(@create_comb, 1:num_el_1-1, 2:num_el_1);
% comb = [c1, c2];
% end
