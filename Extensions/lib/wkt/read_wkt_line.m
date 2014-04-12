function mpoly = read_wkt_line(wkt_str)
if isempty(wkt_str)
    return;
end
%%
[type remain] = strtok(wkt_str, '(');
level = 1;
save = {};
tmp = {};
idr = 1;
%%%
while idr <= numel(remain)
    if strcmp(remain(idr), '(')
        %%
        level = level+1;
        tmp{level} = {};
        idr = idr+1;
    elseif strcmp(remain(idr), ')')
        %%
        level = level-1;
        tmp{level}{end+1} = tmp{level+1};
        idr = idr + 1;
    elseif strcmp(remain(idr), ',')    
        idr = idr + 1;
    else %idr = number
        %%%
        [ring, ~] = strtok(remain(idr:end), ')');
        p = sscanf(ring, '%d %d,', [2 inf]);
        tmp{level} = p;
        idr = idr + numel(ring);
    end
end
mpoly = tmp{level};