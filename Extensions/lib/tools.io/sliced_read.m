function out = sliced_read(column, fid, num_slices, slice_length, num_columns, num_rows)
%% out = sliced_read(column, fid, num_slices, slice_length, num_columns, num_rows)
% reads the column row(s) from the slices matrix that was stored in a file
% column = the column to read from 
% row = the row(s) to read
% fid = file identifier of the stored matrix
% num_slices = the number of slices that where used 
% sliced_length = the number of rows per slice, the last slice can have less rows
% num_columns = total number of columns of stored matrix
% num_rows = total number of rows of stored matrix
% type = the datatype of the matix

if nargin < 6
    error('input not fully defined');
end
out = zeros(num_rows, 1, 'uint8');
fseek(fid, (column-1)*slice_length, -1);
for ids = 1:num_slices    
    idx_out = (1:slice_length)+((ids-1)*slice_length);
    if idx_out(end) > num_rows; 
        idx_out = idx_out(idx_out <= num_rows);
        last_rows = numel(idx_out);
        fseek(fid, -(num_columns-column+1)*last_rows, 1);
    end
    out(idx_out) = fread(fid, numel(idx_out), '*uint8');
    fseek(fid, (num_columns-1)*slice_length, 0);
end

return;
%% test
A = magic(5);
fid = fopen('ftst', 'w+');
fwrite(fid, A, 'uint8');
fwrite(fid, A, 'uint8');
fwrite(fid, A(1:3,:), 'uint8');
%%
for idc = 1:5
    sliced_read(idc, fid, 3, 5, 5, 13)'
end
%%
fclose(fid);

    
