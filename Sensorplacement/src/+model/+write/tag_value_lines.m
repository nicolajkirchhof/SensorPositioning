function tag_value_lines( fid, tag, values, linesz, c_cnt, log_progress)
%OBJ writes out a simple objective function
if nargin < 5
c_cnt = 0;
end

num_vals = size(values,1);
if nargin < 6
log_progress = true;
loop_display(num_vals, 10);
end

for idv = 1:num_vals
    c_add = fprintf(fid, tag, values(idv, :));
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
values = (1:100)';
linesz = 50;
write_log('\ntest 1 ');
tag = '+tst%d ';
model.write.tag_value_lines(1, tag, values, linesz);
write_log('\ntest 2 with 3 values per tst ');
values = [values values values];
tag = '+tst%d ';
model.write.tag_value_lines(1, tag, values, linesz);
write_log('\ntest 2 with 3 values per tst and first line begins at 20');
tag = '+tst%d ';
model.write.tag_value_lines(1, tag, values, linesz, 20);