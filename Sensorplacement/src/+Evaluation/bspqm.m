function solution = bspqm( solution )
%BSPQM Generates all plots for the best sensor pairwise quality model


Evaluation.plots.wss_solution_parsed(solution);
%%
wpn_qualities = zeros(1, solution.discretization.num_positions);
for idw = 1:solution.discretization.num_positions
    varname = sprintf('w%d', idw);    
    wpn_qualities(idw) = sol.variables.value(strcmp(sol.variables.name, varname));
end
solution.solution.wpn_qualities = wpn_qualities;

%% 
Evaluation.draw.bspqm(solution);