function pc = workspace_coverage(pc)

switch pc.workspace.coverage_technique
    case pc.common.sampling_techniques.none
        %%
        warning('manuel k coverage weights must be set');
        pc.problem.W(5,:) = 0;
    case pc.common.sampling_techniques.uniform
        pc.problem.W(5,:) = repmat(pc.workspace.coverage, 1, pc.workspace.number_of_positions);
    otherwise
        error('not implemented');
end