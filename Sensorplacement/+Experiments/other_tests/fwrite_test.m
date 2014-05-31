%% test write performance

bignum = 1e6;
ftest = 'test.tmp';
fid = fopen(ftest, 'w');

tic
c_cnt = 0;
loop_display(bignum, 10);
for idx = 1:bignum
    c_add = fprintf(fid, ' - s%s ', idx);
    c_cnt = c_cnt + c_add;
    if c_cnt > 500        
        fprintf(fid, '\n');
        c_cnt = 0;
    end
    if mod(idx, 1e4)==0
        write_log(loop_display(idx));
    end
end
toc
fclose(fid);

%%
fid = fopen(ftest, 'W');

tic
c_cnt = 0;
loop_display(bignum, 10);
for idx = 1:bignum
    c_add = fprintf(fid, ' - s%s ', idx);
    c_cnt = c_cnt + c_add;
    if c_cnt > 500        
        fprintf(fid, '\n');
        c_cnt = 0;
    end
    if mod(idx, 5e5)==0
        write_log(loop_display(idx));
    end
end
toc
fclose(fid);

%%
fid = fopen(ftest, 'w');

tic
c_cnt = 0;
loop_display(bignum, 10);
c_add = {};
for idx = 1:bignum
    c_add{end+1} = sprintf(' - s%s ', idx);
    c_cnt = c_cnt + numel(c_add{end});
    if c_cnt > 500 
        fprintf(fid, '%s', c_add{:});
        fprintf(fid, '\n');
        c_cnt = 0;
    end
    if mod(idx, 1e4)==0
        write_log(loop_display(idx));
    end
end
c_line = mat2cell(c_add);
fprintf(fid, '%s', c_add{:});
toc
fclose(fid);