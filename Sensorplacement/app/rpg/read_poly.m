function poly = read_poly(filename)
%% load polygon file
% fid = fopen('poly3-001');
fid = fopen(filename);
num_points = fscanf(fid, '%d', 1);
poly = fscanf(fid, '%f', [2, num_points]);
fclose(fid);