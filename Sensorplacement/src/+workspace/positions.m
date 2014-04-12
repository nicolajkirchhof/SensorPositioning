function pc = positions(pc)

if ~pc.progress.environment.load
    pc = environment.load(pc);
end
    
switch pc.workspace.sampling_technique
    case pc.common.sampling_techniques.random
        error('not yet converted to new format');
%         pc = generate_random_workspace_positions(pc);
    case {pc.common.sampling_techniques.uniform, pc.common.sampling_techniques.grid}
        pc = workspace.uniform_positions(pc);
    otherwise
        error('not implemented');
end    

pc.workspace.number_of_positions = size(pc.problem.W, 2);
pc.problem.num_positions = size(pc.problem.W, 2);
if pc.workspace.coverage_technique == pc.common.sampling_techniques.uniform
    pc.problem.k = ones(pc.problem.num_positions, 1)*pc.workspace.coverage;
elseif pc.workspace.coverage_technique == pc.common.sampling_techniques.none
    pc.problem.k = pc.workspace.coverage;
else
    error('no k sampling technique defined');
end

pc.progress.workspace.positions = true;