function [ pc ] = comb_and_sp( pc )
%COMB_AND_SP Combines the relevant combinations with the sameplace constraints

if ~pc.progress.sensorspace.sensorcomb
    pc = sensorspace.sensorcomb(pc);
end
if ~pc.progress.sensorspace.sameplace
    pc = sensorspace.sameplace(pc);
end

pc.problem.spc_ij = ~pc.problem.sp_ij&pc.problem.sc_ij;
[c1, c2] = ind2sub(size(spc_ij), find(spc_ij));
pc.problem.spc_idx = sortrows([c1, c2]);

end

