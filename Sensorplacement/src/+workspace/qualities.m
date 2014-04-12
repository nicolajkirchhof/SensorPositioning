function pc = generate_workspace_qualities(pc)

switch pc.workspace.quality_technique
    case pc.common.sampling_techniques.none
        %%
        pc.problem.W(3,:) = 0;
    case pc.common.sampling_techniques.uniform
        pc.problem.W(3,:) = repmat(pc.workspace.quality, 1, pc.workspace.number_of_positions);
    otherwise
        error('not implemented');
end