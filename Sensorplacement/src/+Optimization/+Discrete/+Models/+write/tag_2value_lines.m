function tag_2value_lines( fid, tag, val1, val2, linesz, c_cnt, log_progress)
%OBJ writes out a simple objective function
if nargin < 6
c_cnt = 0;
end

num_vals = size(val1,1);
if nargin < 7
log_progress = true;
loop_display(num_vals, 10);
end

for idv = 1:num_vals
    c_add = fprintf(fid, tag, val1(idv,:), val2(idv,:));
    c_cnt = c_cnt + c_add;
    % newline with padding to start at same line position
    if c_cnt > linesz
        if log_progress && mod(idv,num_vals/100)<1
            loop_display(idv);
        end;
        fprintf(fid, '\n');
        c_cnt = 0;
    end
end

return;
%% testing
val1 = (1:10)';
val2 = (11:20)';
linesz = 50;
write_log('\ntest 1 ');
tag = '+%d -%d ';
model.write.tag_2value_lines(1, tag, val1, val2, linesz);
write_log('\ntest 2 with 3 values per tst ');
val1 = [val1 val1 val1];
val2 = [val2 val2 val2];
tag = '+%d %d %d -%d %d %d';
model.write.tag_2value_lines(1, tag,  val1, val2, linesz);
write_log('\ntest 2 with 3 values per tst and first line begins at 20');
tag = '+tst%d ';
model.write.tag_2value_lines(1, tag,  val1, val2, linesz, 20);