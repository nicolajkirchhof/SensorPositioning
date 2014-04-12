% function pc = evaluate_coverage(pc)
run c:\users\nico\workspace\tools.common\lib\matlab\custom\matGeom-1.1.5_nico\matGeom\setupMatGeom.m
addpath c:\users\nico\workspace\sensorplacement.thilo\src\matlab\
load testcase1;
selected_sensors = pc.V(pc.solution.sensor_ids);
for ids = 1:numel(selected_sensors); selected_sensors{ids} = [selected_sensors{ids}.x, selected_sensors{ids}.y]'; end;
%%%
method = 3;
num_sensors = numel(selected_sensors);
jobs = {1:num_sensors};
%%% convert to int64 as mm
for ids = 1:num_sensors
    selected_sensors{ids} = int64(selected_sensors{ids}*1000);
end


%%
[poly_covered] = bpolyclip_batch(selected_sensors, method, jobs, true);

%% Test spike removal policy
cla, mb.drawPolygon(selected_sensors(2))
hold on, mb.drawPolygon(selected_sensors(1))
comb = bpolyclip_batch(selected_sensors(1:2), 1, {[1, 2]}, true, 100)
mb.drawPolygon(comb, 'g')
%%
num_polys_job = 100000;
num_jobs = 100;
jobs_mat = randi(num_sensors, num_jobs, num_polys_job);
jobs_cell = mat2cell(jobs_mat, ones(num_jobs,1), num_polys_job)'; 
%%
[poly_covered_repeat] = bpolyclip_batch(selected_sensors, 1, jobs_cell, true);
%% calculate all intersections
ucmb = uniquecmb(combn(1:num_sensors, 2));
ucmblst = mat2cell(ucmb, ones(1, size(ucmb,1)), 2);

% for iduc = 1:numel(ucmblst)
%     disp(iduc);
%     [poly_intersections] = bpolyclip_batch(selected_sensors, method, {ucmblst{iduc}}, true);
% end
%%
tic
[poly_intersections] = bpolyclip_batch(selected_sensors, method, ucmblst, true);
toc
%%
tic 
for iduc = 1:numel(ucmblst)
    [poly_intersections] = bpolyclip(selected_sensors{ucmblst{iduc}(1)}, selected_sensors{ucmblst{iduc}(2)} , method, true);
end
toc