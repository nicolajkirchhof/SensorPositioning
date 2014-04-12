% %% 
% Maximize
%  obj: x1 + 2 x2 + 3 x3 + x4
% Subject To
%  c1: - x1 + x2 + x3 + 10 x4 <= 20
%  c2: x1 - 3 x2 + x3 <= 30
%  c3: x2 - 3.5 x4 = 0
% Bounds
%  0 <= x1 <= 40
%  2 <= x4 <= 3
% General
%  x4
% SOS
% set1: S1:: x1:10 x2:13
% End
% load data\combinations_excerpt.mat num_combs
% load data\combinations.mat 
% load data\set_weigths
% load data\set_weigths_excerpt
fid_out = fopen('data\liga_set_opt.lp', 'w');
fid_cities = zeros(40, 1);
city_values = cell(40, 1);
for idc = 1:num_cities
    fid_cities(idc) = fopen(sprintf('city%d_sets.bin',idc), 'r');
    city_values{idc} =  @(idx) get_value(fid_cities(idc), 'uint32', idx);
end
fid_set_weigths = fopen('set_weigths.bin', 'r');
set_weigths = @(idx) get_value(fid_set_weigths, 'single', idx);
% valid variable identifiers for cplex


%%
% DEBUG
% fid = 1;
% num_combs = 100;
%%%
frewind(fid_out);
fprintf(fid_out, 'Minimize\n');
offset = fprintf(fid_out, ' obj: ');
fprintf(fid_out, c_out);
% for idc = 2:num_combs
num_slices = 16;
slice = nchoosek(40,10)/num_slices;
next_slice = slice;
sw = set_weigths(1:slice)/1e3;
c_out = sprintf('%4.0f %s ', sw(1), cplex_variablename(1));
c_cnt = numel(c_out);
idc = 2;
cnt = 2;
ids = 1;
loop_display(nchoosek(40,10), 10);
flushcnt = 1;
c_offset = repmat(' ', 1, offset);
%%%
while ids <= num_slices
    c_out = sprintf('%s+ %4.0f %s ', c_out, sw(idc), cplex_variablename(cnt));
    c_cnt = c_cnt + numel(c_out);
    if c_cnt > 500
        if flushcnt > 2000
            fprintf(fid, c_out);
            flushcnt = 1;
            c_out = [];
        end
        c_out = sprintf('%s\n%s',c_out, c_offset);
        c_cnt = offset;
        flushcnt = flushcnt + 1;
    end    
    %%%
    idc = idc+1;
    cnt = cnt + 1;
    if cnt > next_slice
        next_slice = next_slice + slice;
        sw = set_weigths(cnt:next_slice)/1e3;
        idc = 1;
        ids = ids + 1;
    end
    if mod(cnt, 100000)==0
    up = loop_display(cnt);
    if ~isempty(up)
        disp(up);
    end
    end
end
fprintf(fid, c_out);
fprintf(fid_out, '\n');
%%
%%%
fprintf(fid_out, 'Subject To\n');
basename = 'NumLeagues_long_name_to_make_sure_that_the_sos_constraints_are_read_';
fullname = [basename repmat('x', 1, 220-numel(basename))];
c_out = sprintf(' %s: s%d ', fullname, 1);
fprintf(fid_out, c_out);
c_cnt = numel(c_out)+numel(fullname);
for idc = 2:num_combs
    c_out = sprintf('+ s%d ', idc);
    c_cnt = c_cnt+numel(c_out);
    if c_cnt > 500
        fprintf(fid_out, '\n%s', repmat(' ', 1, offset));
        c_cnt = offset;
    end
    fprintf(fid_out, c_out);
end
fprintf(fid_out, '= %d\n', 4);
%%%
fprintf(fid_out, 'BINARY\n');
c_cnt = 0;
for idc = 1:num_combs
    c_out = sprintf(' s%d ', idc);
    c_cnt = c_cnt + numel(c_out);
    if c_cnt > 500
        fprintf(fid_out, '\n');
        c_cnt = 0;
    end
    fprintf(fid_out, c_out);
end
fprintf(fid_out, '\n');
%%%
%%%
% clear all;
% load data\idc_value_filter.mat
%%%
% load data\idc_value_filter_excerpt.mat
% num_sets = size(idc_value_filter, 2);
fprintf(fid_out, 'SOS\n');
num_sets = 2;
max_cnt = 100;
cnt = 1;
for ids = 1:num_sets
offset = fprintf(fid_out, ' set%d: S1:: ', ids);
s_id = city_values{ids}(1);
    while ~isempty(s_id)%&& cnt < max_cnt
    c_out = sprintf(' s%d:%d ', s_id, set_weigths(s_id));
    c_cnt = c_cnt + numel(c_out);
    if c_cnt > 500
        fprintf(fid_out, '\n%s', repmat(' ', 1, offset));
        c_cnt = offset;
    end
        fprintf(fid_out, c_out);
        s_id = city_values{ids}([]);
        %cnt = cnt+1;
    end
    %cnt = 0;
    fprintf(fid_out, '\n');
end

% cnt = 1;
% %%%
% idc_occurence = find(idc_value_filter(:,ids))';
% % [unique_set_weights, ~, ic] = unique(set_weights(idc_occurence));
% % num_occurence = histc(set_weights(idc_occurence), unique_set_weights);
% %%%
%     
% 
% for idc = idc_occurence(idc_occurence<=num_combs)
%     fprintf(fid_out, ' s%d:%d ', idc, idc);
%     is_nl = false;
%     if mod(cnt, 10) == 0
%         fprintf(fid_out, '\n');
%         is_nl = true;
%     end
%     cnt = cnt+1;
% end
% if ~is_nl, fprintf(fid_out, '\n'); end
% end
%%
fprintf(fid_out, 'END');
fclose(fid_out);
% 
% set1: S1:: x1:10 x2:13
% End

