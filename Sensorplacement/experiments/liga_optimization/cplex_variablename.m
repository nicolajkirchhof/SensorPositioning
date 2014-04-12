function [name, length] = cplex_variablename(idx)
%%
persistent second_lookup first_lookup num_first num_second in_mem

if isempty(in_mem)
    first_lookup = [33:38 40:41 44 59 63:90 95 97:123 125:126];
    num_first = numel(first_lookup);
    second_lookup = [33:38 40:41 44 46 48:57 59 63:90 95 97:123 125:126];
    num_second = numel(second_lookup);
    in_mem = true;
end

idx_wo_first = idx/num_first;
if idx_wo_first > 0
    length = 1+ceil(log10(idx_wo_first)/log10(num_second));
else 
    length = 1;
end
%%
name = zeros(numel(idx),length);
idx_act = floor(idx_wo_first);
for idn = length:-1:2
    name(idn) = second_lookup(mod(idx_act, num_second)+1);
    idx_act = floor(idx_act/num_second);
end
% idx_first = floor(idx/(num_second^(length-1)));
name(1) = first_lookup(mod(idx, num_first)+1);
name = char(name);
