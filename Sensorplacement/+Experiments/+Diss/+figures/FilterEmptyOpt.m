eval_names = {'conference_room', 'small_flat', 'large_flat', 'office_floor'};
% outdir = '..\..\Dissertation\thesis\figures\';

% for ideval = 1:numel(eval_names)
%%%
ideval = 1;
eval_name = eval_names{ideval};
opts = all_eval.(eval_name);

for ido = 1:numel(opts.mspqm)
    if ~isempty(opts.mspqm{ido})
        if opts.mspqm{ido}.header.solutionStatusValue ~= 101
            disp('investigate!!!');
            break;
        end
    end
end

%%
for ido = 1:numel(opts.bspqm)
    if ~isempty(opts.bspqm{ido})
        if  ~any(opts.bspqm{ido}.header.solutionStatusValue == [101 102])
            opts.bspqm{ido}.header
            fprintf(1, '%d\n', ido);
%             break;
        end
    end
end

% MIP - Time limit exceeded, integer feasible:  Objective =  4.7173233838e+00
% Current MIP best bound =  3.5115458341e+00 (gap = 1.20578, 25.56%)

%% ONLY SCAN % Current MIP best bound after converting it with powershell
tst_strg = 'bspqm_160_large_flat_0_100_.log:833:Current MIP best bound =  1.5116962731e+01 (gap = 4.67125, 23.61%)';
wrong_strg = {'bspqm_114_conference_room_200_100_.log:908:Current MIP best bound =  2.3445079791e+00 (gap = 2.4737, 51.34%)'
'bspqm_119_conference_room_200_150_.log:921:Current MIP best bound =  2.5227305231e+00 (gap = 2.30074, 47.70%)'
'bspqm_129_small_flat_200_0_.log:525:Current MIP best bound =  6.3848024422e+00 (gap = 3.07458, 32.50%)'
'bspqm_137_small_flat_100_100_.log:1371:Current MIP best bound =  1.1500019597e+01 (gap = 2.11953, 15.56%)'
'bspqm_142_small_flat_100_150_.log:1396:Current MIP best bound =  1.1620534040e+01 (gap = 2.66822, 18.67%)'
'bspqm_147_small_flat_100_200_.log:1398:Current MIP best bound =  1.1433989323e+01 (gap = 2.95563, 20.54%)'
'bspqm_157_large_flat_100_50_.log:1302:Current MIP best bound =  1.4310407761e+01 (gap = 5.1351, 26.41%)'
'bspqm_160_large_flat_0_100_.log:833:Current MIP best bound =  1.5116962731e+01 (gap = 4.67125, 23.61%)'
'bspqm_150_large_flat_0_0_.log:1482:Current MIP best bound =  1.5984123495e+01 (gap = 1.95226, 10.88%)'
'bspqm_151_large_flat_50_0_.log:1400:Current MIP best bound =  1.5695876481e+01 (gap = 2.59662, 14.20%)'
'bspqm_152_large_flat_100_0_.log:1346:Current MIP best bound =  1.5304780924e+01 (gap = 2.37332, 13.43%)'
'bspqm_155_large_flat_0_50_.log:1464:Current MIP best bound =  1.5365322170e+01 (gap = 3.56276, 18.82%)'
'bspqm_156_large_flat_50_50_.log:1343:Current MIP best bound =  1.6393736815e+01 (gap = 2.98007, 15.38%)'};

fmt_strg = 'bspqm_%d_%[^_]_%[^_]_%d_%d_.log:%d:Current MIP best bound =  %f (gap = %f, %f%%)';
%%
%% Add bspqm large flat 0 0 to optimizations and paint lower bound in bars
%%
for idstrg = 1:numel(wrong_strg)
% idstrg = 1;
A = textscan(wrong_strg{idstrg}, fmt_strg);

opt_name = 'bspqm';
env_name = [A{2}{1} '_' A{3}{1}];
num_sp = A{4};
id_sp = num_sp/10+1;
num_wpn = A{5};
id_wpn = num_wpn/10+1;
best_bound = A{7};
gap = A{8};
gap_pct = A{9};
bspqm_obj = all_eval.(env_name).(opt_name){id_sp, id_wpn}.header.objectiveValue;
mspqm_obj = all_eval.(env_name).mspqm{id_sp, id_wpn}.header.objectiveValue;
fprintf(1, 'bspqm %g mspqm %g gap %g pct %g\n', bspqm_obj, mspqm_obj, gap, gap_pct);
end


% fid = fopen('tmp\bspqm\bspqm_log_eval.txt');