function loop_display(iteration, update_interval)
persistent tme next iterations stp
if nargin > 1
    stp = update_interval;
    tme = tic;
    next = update_interval;
    iterations = iteration(1);
end

if toc(tme)>next
    write_log('%g pct %g sec to go\n', iteration*100/iterations, (toc(tme)/iteration)*(iterations-iteration));
    next = toc(tme)+stp;
end
return;
%% testing
loop_display(10,1);
for i = 1:10
    pause(0.9);
    loop_display(i)
end

%% testing
loop_display(1e9,1);
for i = 1:1e9
    magic(10);
    write_log(loop_display(i));
end
    