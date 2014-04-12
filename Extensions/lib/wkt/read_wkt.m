function mpolys = read_wkt(filename)
%%
fid = fopen(filename);

lines = {fgetl(fid)};
while ischar(lines{end})
    lines{end+1} = fgetl(fid);
end
lines = lines(1:end-1);

mpolys = cellfun(@read_wkt_line, lines);
fclose(fid);

