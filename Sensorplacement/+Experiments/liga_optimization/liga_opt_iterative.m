%% iterative liga optimization
filename = 'data\Combinations_40_10.bcomb';
filename_out = 'data\combination_values.bin';
finfo = dir(filename);
fid = fopen(filename);
fido = fopen(filename_out, 'w');
%%


%% Load combinations_values
% num_comb = finfo.bytes/8;
% frewind(fid);
% pct = floor(num_comb/100);
% combs = zeros(num_comb, 8, 'uint8');
% for i = 1:num_comb+1
%     combs(i, :) = fread(fid,[1 8], '*uint8');
%     if mod(i,pct)==0 
%         disp(i/num_comb);
%     end
% end
%% Calculate set weights
frewind(fid);
frewind(fido);
tic
pct = 0;
steps = 1000;
idcomb_start = 0;
for idcomb = 0:finfo.bytes/8
    %     idcomb = idfile/8;
    comb_values = fread(fid, 8, '*uint8');
    comb_dist_idx = comb2unique(comb_values'+1);
    comb_dist_ind = sub2ind([40 40], comb_dist_idx(:,1), comb_dist_idx(:,2));
    comb_set_distance = sum(distance_matrix(comb_dist_ind));
    
    fwrite(fido, comb_set_distance, 'uint64');
    
    if pct < floor(idcomb*steps/(finfo.bytes/8))
        %%
        pct = floor(idcomb*steps/(finfo.bytes/8));
        rest_time = toc/pct*(steps-pct);
        fprintf(1,'%d pct %g sec to go\n', pct*steps, rest_time);
    end
end

fclose(fido);
fclose(fid);

%% Load and evaluate set weights

fido = fopen(filename_out, 'r');
fido_info = dir(filename_out);
num_comb = fido_info.bytes/8;
%%
frewind(fido);
pct = floor(num_comb/100);
eval = zeros(1, num_comb, 'uint64');
for i = 1:num_comb
    eval(i) = fread(fido, 1, 'uint64');
    if mod(i,pct)==0 
        disp(i/num_comb);
    end
end

%% Calculate SOS 

load data\combinations.mat
%%
% each column represents an input var, the rows are true if input var is contained in this set
idc_value_filter = zeros(size(combs, 1), 40, 'uint8');
for idc = 0:39
    idc_value_filter(:,idc+1) = any(combs==idc, 2);
    disp(idc);
end


