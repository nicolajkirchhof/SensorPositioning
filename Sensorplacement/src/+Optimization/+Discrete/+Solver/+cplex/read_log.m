function [ sol ] = read_log( problemfile )
%READ_LOG Summary of this function goes here
%   Detailed explanation goes here

% get full path
[path, base] = fileparts(problemfile);
% if ~isempty(strtrim(path))
%     addpath(path);
% end
problemfile = which(problemfile);
log_file = [path filesep base '.cplog'];
if ~exist(log_file, 'file')
    warning('log to file %s does not exist', problemfile);
    return;
end
   
        flog = fopen(log_file);
        slne = fgetl(flog);
        while isempty(strfind(slne, 'Nodes')) && ischar(slne)
            slne = fgetl(flog);
        end
        %%
        num_table_entries = 100;
        sol.table = cell(1,num_table_entries);
%         sol.table{end+1} = slne;
        idts = (1:num_table_entries)';
        while isempty(strfind(slne, 'Root node processing')) && ischar(slne)
            slne = fgetl(flog);
            idt = idts(1);
            sol.table{idt} = slne;
            idts = circshift(idts, -1);
        end
        %% find last log properties
        idt = num_table_entries-1;
        stmp = char(sscanf(sol.table{idts(idt)}, '%s'));
        while idt > 0 && (isempty(stmp) || strcmp(stmp(1), '*') == 0)
             stmp = char(sscanf(sol.table{idts(idt)}, '%s'));
             idt = idt - 1;
        end
        if idt > 0
            sbest = sol.table{idts(idt+1)};
            [tbest, rest] = strtok(sbest, ' ');
            [tnode, rest] = strtok(strtrim(rest), ' ');
            % skip the next 20 char
            num_skip = numel('     Objective  IInf');
            rest = rest(num_skip+1:end);
            [tbestint, rest] = strtok(strtrim(rest), ' ');
            [tbestbound, rest] = strtok(strtrim(rest), ' ');
            [titcnt, rest] = strtok(strtrim(rest), ' ');
            [tgap, rest] = strtok(strtrim(rest), '%');
            
%             sol.best = num2str(tbest);
            sol.node = num2str(tnode);
            sol.bestint = num2str(tbestint);
            sol.bestbound = num2str(tbestbound);
            sol.itcnt = num2str(titcnt);
            sol.gap = num2str(tgap);
        end
        %%
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         [rt] = sscanf(stmp, 'Realtime=%fsec.(%fticks)');
         sol.rtbeforebc_sec = rt(1);
         sol.rtbeforebc_ticks = rt(2);
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         sol.threads = sscanf(stmp, 'Parallelb&c,%dthreads:');
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         [rt] = sscanf(stmp, 'Realtime=%gsec.(%gticks)');
         sol.rtbc_sec = rt(1);
         sol.rtbc_ticks = rt(2);
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         sol.synctime = sscanf(stmp, 'Synctime(average)=%fsec.');
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         sol.waittime = sscanf(stmp, 'Waittime(average)=%fsec.');
         fgetl(flog);
         slne = fgetl(flog);
         stmp = char(sscanf(slne, '%s'));
         [tt]  = sscanf(stmp, 'Total(root+branch&cut)=%f sec.(%f ticks)');
           sol.total_sec = tt(1);
           sol.total_ticks = tt(2);
         fclose(flog);

end

