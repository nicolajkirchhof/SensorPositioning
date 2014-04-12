%% generate variable names up to a custom size and write to file


first_lookup = [33:38 40:41 44 59 63:90 95 97:123 125:126];
num_first = numel(first_lookup);
second_lookup = [33:38 40:41 44 46 48:57 59 63:90 95 97:123 125:126];
num_second = numel(second_lookup);

num_names = nchoosek(40,10);
idx_wo_first = num_names/num_first;
length = 1+ceil(log10(idx_wo_first)/log10(num_second));
fid_names = fopen('names_lookup.txt', 'w');
fid_names = 1;

%%
cnt = 1;
c_cnt1 = 1;
c_cnt = zeros(1,length-1);
frewind(fid_names);
while cnt <= num_names
    c_cnt1 = c_cnt1+1;
    if c_cnt1 > num_first
        c_cnt1 = 1;
        c_cnt(2) = c_cnt(2) + 1;
        chk_id = 2;
        while chk_id < 4 && (c_cnt(chk_id) + 1) > num_second;
            c_cnt(chk_id) = 1;
            c_cnt(chk_id+1) = c_cnt(chk_id+1) + 1;
            chk_id = chk_id+1;
        end
    end
    cnt = cnt+1;
    fprintf(fid_names, '%s%s\n', first_lookup(c_cnt1), second_lookup(c_cnt(c_cnt>0)));
    if mod(cnt, 100000)==0
        disp(cnt/num_names);
    end
end
%%




idx_wo_first = idx/num_first;
if idx_wo_first > 0
    length = 1+ceil(log10(idx_wo_first)/log10(num_second));
else 
    length = 1;
end
%%
name = zeros(1,length);
idx_act = floor(idx_wo_first);
for idn = length:-1:2
    name(idn) = second_lookup(mod(idx_act, num_second)+1);
    idx_act = floor(idx_act/num_second);
end
% idx_first = floor(idx/(num_second^(length-1)));
name(1) = first_lookup(mod(idx, num_first)+1);
name = char(name);
