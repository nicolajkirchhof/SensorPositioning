%% eval all solutions
close all; clear all; fclose all;
subdir = 'irf_seminar';
%  subdir = 'p1_01_excerpt';

 sfiles = dir(['data\solutions\' subdir '\*.mat']);
 ids = 1;
 %
 allowedtags = {'_coverage', '_sameplace' '_qclip' '_sc_backward' '_qcontinous_sub' 'sc_forward' 'sc_ind'};
%  forbiddentags = {
%  fsaved = 'data\evals\all_evals.mat';
% load(fsaved);
% res_saved = res;
% tbr = [];
%  for ids = 1:numel(res_saved.fname)
%       [~, basesaved] = fileparts(res_saved.fname{ids});
%       for idf = 1:numel(sfiles)
%           [~, nname] = fileparts(sfiles(idf).name);
%           if strcmp(basesaved, nname)
%               tbr(end+1) = idf;
%           end
%       end
%  end
% sfiles_flt = true(numel(sfiles), 1);
% sfiles_flt(tbr) = false;
% sfiles = sfiles(sfiles_flt);
 %%
 
 %
res.wp = nan(numel(sfiles), 1);
res.sp = nan(numel(sfiles), 1);
res.sc = nan(numel(sfiles), 1);
res.ap = nan(numel(sfiles), 1);
res.up = nan(numel(sfiles), 1);
res.suad = nan(numel(sfiles), 1);
res.wpgd = nan(numel(sfiles), 1);
res.supd = nan(numel(sfiles), 1);
res.time = nan(numel(sfiles), 1);
res.mipit = nan(numel(sfiles), 1);
res.sstat = nan(numel(sfiles), 1);
res.numsensors = nan(numel(sfiles), 1);
res.objective = nan(numel(sfiles), 1);
res.qual =  nan(numel(sfiles), 1);
res.fname = cell(numel(sfiles), 1);
res.lname = cell(numel(sfiles), 1);
res.tags =  nan(numel(sfiles), numel(allowedtags));
res.table = cell(numel(sfiles), 1);
res.realtime.sec = nan(numel(sfiles), 1);
res.realtime.ticks = nan(numel(sfiles), 1);
res.realtimeth.sec = nan(numel(sfiles), 1);
res.realtimeth.ticks = nan(numel(sfiles), 1);
res.threads = nan(numel(sfiles), 1);
res.synctime = nan(numel(sfiles), 1);
res.waittime = nan(numel(sfiles), 1);
res.total.sec = nan(numel(sfiles), 1);
res.total.ticks = nan(numel(sfiles), 1);
 %
for ids = 1:numel(sfiles)
    disp(ids)
% for ids = 1:10
    %%
    %%
    fn = sfiles(ids).name;
    res.fname{ids} = ['data\evals\' subdir filesep fn];
    res.lname{ids} = ['data\logs\' strrep(fn, '.mat', '.cplog')];
    
    if exist(res.lname{ids}, 'file')
        flog = fopen(res.lname{ids});
        %%
        slne = fgetl(flog);
        while isempty(strfind(slne, 'Nodes')) && ischar(slne)
            slne = fgetl(flog);
        end
        %%
        res.table{ids} = {};
        res.table{ids}{end+1} = slne;
        while isempty(strfind(slne, 'Root node processing')) && ischar(slne)
            slne = fgetl(flog);
%             res.table{ids}{end+1} = slne;
        end
        %%
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         [rt] = sscanf(stmp, 'Realtime=%fsec.(%fticks)');
         res.realtime.sec(ids) = rt(1);
         res.realtime.ticks(ids) = rt(2);
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         res.threads(ids) = sscanf(stmp, 'Parallelb&c,%dthreads:');
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         [rt] = sscanf(stmp, 'Realtime=%gsec.(%gticks)');
         res.realtimeth.sec(ids) = rt(1);
         res.realtimeth.ticks(ids) = rt(2);
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         res.synctime(ids) = sscanf(stmp, 'Synctime(average)=%fsec.');
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         res.waittime(ids) = sscanf(stmp, 'Waittime(average)=%fsec.');
         fgetl(flog);
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         [tt]  = sscanf(stmp, 'Total(root+branch&cut)=%f sec.(%f ticks)');
           res.total.sec(ids) = tt(1);
           res.total.ticks(ids) = tt(2);
         fclose(flog);
    end
end
return
%     if exist(res.fname{ids}, 'file')
%         save(res.fname{ids}, 'pc', 'sol');
%     else
    sol = load(['data\solutions\' subdir filesep fn]);
    if isfield(sol, 'x')
        sol = sol.x;
    else
        sol = sol.sol;
    end
    props = false(numel(allowedtags),1);
    for idtag =1:numel(allowedtags)
        tag = allowedtags{idtag};
        props(idtag) = ~isempty(strfind(fn, tag));
        if props(idtag)
            fn = strrep(fn, tag, '');
        end
    end
    fconfig = ['data\configs\' subdir filesep fn];
    if exist(fconfig, 'file')
        config = load(fconfig);
        pc = config.pc;
    end
%     if ~exist(res.fname{ids}, 'file')
    res.tags(ids,:) = props';
    save(res.fname{ids}, 'pc', 'sol');
%     end
% end
% %%
% for ids = 1:numel(sfiles)
    clear pc sol
    load(res.fname{ids}, 'pc', 'sol');
        %%
    res.wp(ids) = pc.problem.num_positions;
    res.sc(ids) = pc.problem.num_comb;
    res.sp(ids) = pc.problem.num_sensors;
    res.ap(ids) = pc.sensorspace.number_of_angles_per_position;
    res.up(ids) = size(unique(pc.problem.S(1:2,:)', 'rows', 'sorted'), 1);
    res.suad(ids) = pc.sensorspace.uniform_angle_distance;
    res.supd(ids) = pc.sensorspace.uniform_position_distance;
    res.wpgd(ids) = pc.workspace.grid_position_distance;
    res.mipit(ids) = sol.header.MIPIterations;
    res.sstat(ids) = sol.header.solutionStatusValue;
    res.objective(ids) = sol.header.objectiveValue;

    %%
    solnames = sol.variables.name(sol.variables.value(1:numel(sol.variables.name))==1);
    sol_ids = unique(cell2mat(cellfun(@(str) sscanf(str, 's%d'), solnames, 'uniformoutput', false)'));
%%     
    res.numsensors(ids) = numel(sol_ids);
    %%
    ucomb = comb2unique(sol_ids);
    [~, ia] = intersect(pc.problem.sc_idx, ucomb, 'rows');
    res.qual(ids) = sum(pc.quality.wss_dd_dop.valbw(ia));
    disp(ids);
% end

% function eval_table(flt)
%%
fun_stat_table =@(flt) ...
    fprintf('%3d \t %3d \t %4g \t %3d \t %3d \t %2d \t %6g \t %2d \t %6g\n', [find(flt), res.supd(flt), rad2deg(res.suad(flt)),...
    res.wpgd(flt), res.up(flt), res.ap(flt), res.total.sec(flt), res.numsensors(flt), res.objective(flt)]');
% %
% for fn = fieldnames(res)
%     fn = fn{1};
%     res_saved.(fn) = [res_saved.(fn) res.(fn)];
% end

cov_flt = (res.tags(:,1) == 1)&~(any(res.tags(:,2:end),2));
res.fname(cov_flt);
sp_flt = (res.tags(:,2) == 1)&~(any(res.tags(:,3:end),2));
res.fname(sp_flt);
approx_flt = (res.tags(:,3) == 1)&~(any(res.tags(:,4:end),2));
res.fname(approx_flt);

 qcont_flt = (res.tags(:,5) == 1)&~(any(res.tags(:,6:end),2));
 res.fname(qcont_flt);

qclip_flt = all(res.tags(:,1:3) == 1,2)&~(any(res.tags(:,6:end),2));
res.fname(qclip_flt);

qall_flt = cov_flt | sp_flt | approx_flt | qcont_flt | qclip_flt;

