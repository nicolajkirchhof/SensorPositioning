num_wpns = 0:10:500;
num_sps =  0:10:500;
iteration = 0;
update_interval = 5;
stp = update_interval;
tme = tic;
next = update_interval;
iterations = numel(num_wpns)*numel(num_sps);
write_log([], '#off');

for id_wpn = 1:numel(num_wpns)
    for id_sp = 1:numel(num_sps)
        num_wpn = num_wpns(id_wpn);
        num_sp = num_sps(id_sp);
        
        %%
%         num_wpn = 10;
%         num_sp = 10;
        Experiments.Diss.conference_room(num_sp, num_wpn);
        Experiments.Diss.small_flat(num_sp, num_wpn);
%         Experiments.Diss.large_flat(num_sp, num_wpn);
%         Experiments.Diss.office_floor(num_sp, num_wpn);

        %%
        iteration = iteration + 1;
        if toc(tme)>next
            fprintf(1, '%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
            next = toc(tme)+stp;
        end
    end
end