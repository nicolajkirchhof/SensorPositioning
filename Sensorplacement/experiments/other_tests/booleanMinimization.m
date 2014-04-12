%% testing bool minimization
%%
num_syms = 100;
num_comb = 50;
S = sym('s', [1 syms]);
Y = sym('y', [1 num_comb]);
for ids = 2:2:numel(S)
    Y(ids) = S(ids)&S(ids-1);
    for idsn = 2:2:ids
        Y(ids) = Y(ids)&~(S(idsn)&S(idsn-1));
    end
end