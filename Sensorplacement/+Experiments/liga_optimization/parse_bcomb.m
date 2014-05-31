% function comb = parse_bcomb(filename);
%% parse bcomb binary combination file

finfo = dir(filename);
fid = fopen(filename);

%%

comb = fread(fid, finfo.bytes, 'uint8');