%% solve problem without sameplace constraint
pc = model_problem(pc);
pc.cplex.solve();
pc.problem.solution = pc.cplex.Solution;
[find(pc.problem.solution.x) pc.problem.solution.x(find(pc.problem.solution.x))]
cla, draw_cplex_solution(pc);
%%
%% build model with sameplace constraints
cp = pc.cplex;
%%%
cp.Model.A = [pc.model.coverage.A;
   pc.model.sameplace.A];
%%%
cp.Model.rhs = [pc.model.coverage.rhs;    
   pc.model.sameplace.rhs];
cp.Model.lhs = [pc.model.coverage.lhs;
   pc.model.sameplace.lhs];
cp.Model.ctype = [pc.model.coverage.ctype];
cp.Model.obj = [pc.model.coverage.obj];
cp.Model.lb = pc.model.coverage.lb;
cp.Model.ub = pc.model.coverage.ub;
%%%
cp.solve();
pc.problem.solution = cp.Solution;
[find(cp.Solution.x) cp.Solution.x(find(cp.Solution.x))]

cla, draw_cplex_solution(pc);

%% model with sameplace and quality
cp = pc.cplex;
num_combonst = pc.model.quality.directional.num_columns-pc.model.coverage.num_columns;
%%%
cp.Model.A = [ [pc.model.coverage.A, sparse(size(pc.problem.xt_ij,2), num_combonst)];
   pc.model.sameplace.A, sparse(size(pc.model.sameplace.A, 1), num_combonst);
   pc.model.quality.directional.A];
%%%
cp.Model.rhs = [pc.model.coverage.rhs;    
   pc.model.sameplace.rhs;
   pc.model.quality.directional.rhs];
cp.Model.lhs = [pc.model.coverage.lhs;
   pc.model.sameplace.lhs;
   pc.model.quality.directional.lhs];
cp.Model.ctype = [pc.model.coverage.ctype, pc.model.quality.directional.ctype];
cp.Model.obj = [pc.model.coverage.obj; pc.model.quality.directional.obj];
cp.Model.lb = [pc.model.coverage.lb; pc.model.quality.directional.lb ];
cp.Model.ub = [pc.model.coverage.ub; pc.model.quality.directional.ub ];

%%
% TODO CHECK IF SUM SELECTED IS > 0
cp.solve();
pc.problem.solution = cp.Solution;
[find(cp.Solution.x) cp.Solution.x(find(cp.Solution.x))]
cla, draw_cplex_solution(pc);

