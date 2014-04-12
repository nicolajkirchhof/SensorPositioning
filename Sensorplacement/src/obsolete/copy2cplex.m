function copy_cplex_fields(str, cplex)
%%
valid_fieldnames = {'A', 'ctype', 'obj', 'lb', 'ub', 'lhs', 'rhs', 'sense', 'rowname', 'colname'};
for fn = fieldnames(str)'
    if any(strcmpi(fn{1}, valid_fieldnames))
        cplex.Model.(fn{1}) = str.(fn{1});
    end
end