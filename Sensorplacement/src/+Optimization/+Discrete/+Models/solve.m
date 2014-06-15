function cplex = solve( pc )
%SOLVE Solves the current
%   Detailed explanation goes here

if isempty(pc.name)
  pc.name = 'sample';
end
cplex = Cplex(pc.name);
copy_cplex_fields(pc.model.cplex, cplex);
cplex.solve();

end

