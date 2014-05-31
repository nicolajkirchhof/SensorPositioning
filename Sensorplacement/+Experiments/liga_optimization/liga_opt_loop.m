%% iterative file supported liga opt
load data\liga_opt_relevant.mat
num_cities = 40;
num_leagues = 4;
k = num_cities/num_leagues;
num_comb = nchoosek(num_cities,10);
combination = [1, 2, 3, 4, 5, 6, 7, 8, 9, 9];
%%% tests
% combination = [1, 2, 3, 4, 5, 6, 7, 8, 39, 40];
% combination = [1, 2, 3, 4, 5, 6, 7, 38, 39, 40];

%%
fid_set_weigths = fopen('set_weigths.bin', 'w');
fid_cities = zeros(num_cities, 1);
city_cache_limit = 1e7;
city_cache = zeros(city_cache_limit, num_cities, 'uint32');
city_cache_last = ones(40,1);
for idc = 1:num_cities
    fid_cities(idc) = fopen(sprintf('city%d_sets.bin',idc), 'w');
end
%%
idcomb = 1;
tic
update = 10;
next_update = update;
iterations = num_comb;
% iterations = 1e5;
% while idcomb <= num_comb
lastpos = 0;
k_idx = comb2unique(1:k);
%%%
while idcomb <= iterations
    %%
    combination(end) = combination(end)+1;
    % propagate increase to front
    if combination(end)>40
        trigger = 40;
        while any(combination>=trigger)
            pos = find(combination>=trigger, 1, 'first');
            %         if pos == 1; break; end;
            trigger = trigger-1;
            combination(pos) = 0;
        end
        combination(pos-1) = combination(pos-1)+1;
        combination(pos:k) = (1:k-pos+1)+combination(pos-1); 
    end
%         disp(combination);
%     end
    %% write combination to each city file
    cc_ind = sub2ind(size(city_cache),  city_cache_last(combination), combination');
    city_cache(cc_ind) = idcomb;
    city_cache_last(combination) = city_cache_last(combination)+1;
    if any(city_cache_last>city_cache_limit)
        for idc = find(city_cache_last>city_cache_limit)'
            fwrite(fid_cities(idc), city_cache(:,idc), 'uint32');
            city_cache_last(idc) = 1;
        end
    end
    
    comb_dist_ind = sub2ind([40 40], combination(k_idx(:,1)), combination(k_idx(:,2)));
    comb_set_distance = sum(distance_matrix(comb_dist_ind));
    fwrite(fid_set_weigths, comb_set_distance, 'single');
    %     set_weights(idcomb) = uint16(comb_set_distance/100000); %store in 1000km
    
    idcomb=idcomb+1;
    if toc > next_update
        %%
        pct = idcomb*100/iterations;
        rest_time = (toc/idcomb)*(iterations-idcomb);
        fprintf(1,'%g pct %g sec to go\n', pct, rest_time);
        next_update = toc+update;
    end
end
for idc = 1:num_cities
    fwrite(fid_cities(idc), city_cache(1:city_cache_last(idc)-1,idc), 'uint32');
    city_cache_last(idc) = 1;
end
fclose all;

%%
% fid_set_weigths = fopen('set_weigths.bin', 'r');
% for idc = 1:num_cities
%     fid_cities(idc) = fopen(sprintf('city%d_sets',idc), 'r');
%     
% end
    


%% iterative liga optimization
% load data\liga_opt_relevant.mat
% num_comb = nchoosek(40,10);
% set_weights = zeros(num_comb,1,'uint16');
% allcombs_1 = zeros(num_comb,1,'uint32');
% allcombs_2 = zeros(num_comb,1,'uint8');
% combination = [1, 2, 3, 4, 5, 6, 7, 8, 9, 9];
%
% idcomb = num_comb;
% tic
% pct = 0;
% steps = 1000;
% iterations = num_comb;
% while idcomb <= num_comb
%     combination(end) = combination(end)+1;
%     while any(combination>40)
%         pos = find(combination>40, 1, 'last');
%         if pos == 1; break; end;
%         combination(pos) = 1;
%         combination(pos-1) = combination(pos-1)+1;
%     end
%     disp(combination);
% end
%     %% write combination
%     allcombs_1(idcomb) = sum(bitset(uint32(0), combination(combination<=32),'uint32'));
%     allcombs_2(idcomb) = sum(bitset(uint8(0), combination(combination>32)-32,'uint8'));
%
%     comb_dist_idx = comb2unique(combination);
%     comb_dist_ind = sub2ind([40 40], comb_dist_idx(:,1), comb_dist_idx(:,2));
%     comb_set_distance = sum(distance_matrix(comb_dist_ind));
%     set_weights(idcomb) = uint16(comb_set_distance/100000); %store in 1000km
%
%     idcomb=idcomb+1;
%         if pct < floor(idcomb*steps/num_comb)
%         %%
%         pct = floor(idcomb*steps/num_comb);
%         rest_time = (toc/pct)*(steps-pct);
%         fprintf(1,'%d pct %g sec to go\n', pct, rest_time);
%         end
% end
% %% Calculate set weights
% frewind(fid);
% frewind(fido);
% tic
% pct = 0;
% steps = 1000;
% idcomb_start = 0;
% for idcomb = 0:finfo.bytes/8
%     %     idcomb = idfile/8;
%     comb_values = fread(fid, 8, '*uint8');
%     comb_dist_idx = comb2unique(comb_values'+1);
%     comb_dist_ind = sub2ind([40 40], comb_dist_idx(:,1), comb_dist_idx(:,2));
%     comb_set_distance = sum(distance_matrix(comb_dist_ind));
%
%     fwrite(fido, comb_set_distance, 'uint64');
%
%     if pct < floor(idcomb*steps/(finfo.bytes/8))
%         %%
%         pct = floor(idcomb*steps/(finfo.bytes/8));
%         rest_time = toc/pct*(steps-pct);
%         fprintf(1,'%d pct %g sec to go\n', pct*steps, rest_time);
%     end
% end
%
% fclose(fido);
% fclose(fid);
%
% %% Load and evaluate set weights
%
% fido = fopen(filename_out, 'r');
% fido_info = dir(filename_out);
% num_comb = fido_info.bytes/8;
% %%
% frewind(fido);
% pct = floor(num_comb/100);
% eval = zeros(1, num_comb, 'uint64');
% for i = 1:num_comb
%     eval(i) = fread(fido, 1, 'uint64');
%     if mod(i,pct)==0
%         disp(i/num_comb);
%     end
% end
%
% %% Calculate SOS
%
% load data\combinations.mat
% %%
% % each column represents an input var, the rows are true if input var is contained in this set
% idc_value_filter = zeros(size(combs, 1), 40, 'uint8');
% for idc = 0:39
%     idc_value_filter(:,idc+1) = any(combs==idc, 2);
%     disp(idc);
% end
%
%
