function pc = generate_workspace_priorities(pc)

switch pc.workspace.priority_technique
    case pc.common.sampling_techniques.none
        %%
        pc.problem.W(4,:) = 0;
    case pc.common.sampling_techniques.uniform
        pc.problem.W(4,:) = repmat(pc.workspace.priority, 1, pc.workspace.number_of_positions);
    otherwise
        error('not implemented');
end