function pc = build_cplex_model(pc)
% all properties about how to assemble the cplex model are defined in
% pc.model
pc.problem.cplex.Model.A = pc.problem.xt_ij';

%% CONTINUE HERE
switch pc.model.lower_bound
    case pc.model.coverage.cutoff.lower_types.none
        pc.problem.cplex.Model.lhs = ;


if pc.model.use_sameplace_constraints || pc.model.use_quality_constraints
 %% sameplace constraints do not add additional colums to the opt vector   
pc.problem.cplex.Model.A = [
    pc.problem.xt_ij'; 
    pc.model.sameplace.A ];
pc.problem.cplex.Model.rhs = [ 
    inf(size(pc.problem.W(5,:)))'; 
    rhs_one_sensortype; 
    pc.model.coverage.cutoff.upper;
    pc.model.sameplace.rhs];
pc.problem.cplex.Model.lhs = double([ 
    pc.problem.W(5,:)'; 
    lhs_one_sensortype; 
    pc.model.coverage.cutoff.lower;
    pc.model.sameplace.lhs ]);
pc.problem.cplex.Model.ctype = repmat('B', 1, numel(pc.problem.ct));
pc.problem.cplex.Model.obj = pc.problem.ct;
pc.problem.cplex.Model.lb = zeros(size(pc.problem.ct));
pc.problem.cplex.Model.ub = ones(size(pc.problem.ct));
end
    





sensor_sum = ones(1, pc.problem.num_sensors);

pc.problem.cplex = Cplex('sensorplacement');

% The objective is to minimize the number of sensors to be applied to the
% workspace
pc.problem.cplex.Model.sense = 'minimize';
%%
% MAKE SURE ALL VALUES ARE DOUBLE
pc.problem.cplex.Model.A = [
    pc.problem.xt_ij'; 
    A_one_sensortype; 
    sensor_sum; 
    pc.model.sameplace.A ];
pc.problem.cplex.Model.rhs = [ 
    inf(size(pc.problem.W(5,:)))'; 
    rhs_one_sensortype; 
    pc.model.coverage.cutoff.upper;
    pc.model.sameplace.rhs];
pc.problem.cplex.Model.lhs = double([ 
    pc.problem.W(5,:)'; 
    lhs_one_sensortype; 
    pc.model.coverage.cutoff.lower;
    pc.model.sameplace.lhs ]);
pc.problem.cplex.Model.ctype = repmat('B', 1, numel(pc.problem.ct));
pc.problem.cplex.Model.obj = pc.problem.ct;
pc.problem.cplex.Model.lb = zeros(size(pc.problem.ct));
pc.problem.cplex.Model.ub = ones(size(pc.problem.ct));


