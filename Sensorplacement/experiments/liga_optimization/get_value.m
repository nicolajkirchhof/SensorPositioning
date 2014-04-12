function v  = get_value(fid, type, idx)
switch type
    case {'uint32', 'single'}
        v = read_4_byte(fid, ['*' type], idx);
end

function v = read_4_byte(fid, type, idx)

if ~isempty(idx)
    if ftell(fid) ~= (idx(1)-1)*4
        res = fseek(fid, (idx(1)-1)*4, -1);
        if res < 0
            v = [];
            return
        end
    end
else
    idx = 1;
end
v = fread(fid, numel(idx), type);

