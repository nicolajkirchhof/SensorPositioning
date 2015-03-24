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
sscanf

fid = fopen('tmp\bspqm\bspqm_log_eval.txt');