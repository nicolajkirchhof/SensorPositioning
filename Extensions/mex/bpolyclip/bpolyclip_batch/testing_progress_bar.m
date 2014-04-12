%% progress bar extensive testing
load c:\Users\nico\workspace\sensorplacement.thilo\env1_quality_1_sin_calculated.mat
% save c:\Users\nico\workspace\sensorplacement.thilo\env1_quality_1_sin_calculated.mat
%%
% jobs = mat2cell(unique_combinations, ones(num_unique_combinations,1), 2);
% xing_polys = bpolyclip_batch(pc.problem.V, 0, jobs, true, 0, 1, 10);
%%
xing_polys = bpolyclip_batch(pc.problem.V, 1, unique_combinations, true, 1, 1, 10);
