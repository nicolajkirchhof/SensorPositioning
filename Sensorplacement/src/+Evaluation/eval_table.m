% function eval_table(flt)
%%

cov_flt = (res.tags(:,1) == 1)&~(any(res.tags(:,2:end),2));
res.fname(cov_flt);
sp_flt = (res.tags(:,2) == 1)&~(any(res.tags(:,3:end),2));
res.fname(sp_flt);
approx_flt = (res.tags(:,3) == 1)&~(any(res.tags(:,4:end),2));
res.fname(approx_flt);

 qcont_flt = (res.tags(:,5) == 1)&~(any(res.tags(:,6:end),2));
 res.fname(qcont_flt);

qclip_flt = all(res.tags(:,1:3) == 1,2)&~(any(res.tags(:,6:end),2));
res.fname(qclip_flt);

qall_flt = cov_flt | sp_flt | approx_flt | qcont_flt | qclip_flt;


 fun_table_values = @(flt)  [...
    find(flt), res.sc(flt), res.supd(flt), rad2deg(res.suad(flt)),...
    res.wpgd(flt), res.sp(flt),res.wp(flt),res.up(flt), res.ap(flt), res.total.sec(flt), res.numsensors(flt), res.objective(flt), sum(res.tags(flt,:)*(1:2:14)',2), res.qual(flt)./res.wp(flt)];

fun_stat_table =@(flt) ...    
    fprintf('%3d,%6g,%3d,%4g,%3d,%3d,%3d,%3d,%2d,%6g,%2d,%6g,%3d,%6g\n', fun_table_values(flt)');
    %        idx tot sup sua wpg sp  wp  up  ap  sec ns  obj        

     fun_table2_values = @(flt)  [...
    find(flt), res2.sc(flt), res2.supd(flt), rad2deg(res2.suad(flt)),...
    res2.wpgd(flt), res2.sp(flt),res2.wp(flt),res2.up(flt), res2.ap(flt), res2.total.sec(flt), res2.numsensors(flt), res2.objective(flt), sum(res2.tags(flt,:)*(1:2:14)',2), res2.qual(flt)./res2.wp(flt)];

fun_stat2_table =@(flt) ...    
    fprintf('%3d,%6g,%3d,%4g,%3d,%3d,%3d,%3d,%2d,%6g,%2d,%6g,%3d,%6g\n', fun_table2_values(flt)');
    %        idx tot sup sua wpg sp  wp  up  ap  sec ns  obj        

% fun_sort_table =@(flt, idx) ...
%     fprintf('%6g %3d %3d %4g %3d %3d %2d %6g %2d %6g\n', fun_table_values(flt)');


% fun_new_table = @(tbl) ...
%     fprintf('%3d   %3d   %4g   %3d   %3d   %2d   %6g   %2d   %6g\n', tbl);
%%
unfi_flt = (res.total.sec>28000) & (qclip_flt|qcont_flt);
unfi = res.table(unfi_flt);
disp('-----');
stats = {};
for idf = 1:numel(unfi)
    stats{end+1} = unfi{idf}{end-9};
end
stats{10} = unfi{10}{end-8};

valstat = nan(numel(unfi), 1);
for idf = 1:numel(unfi)  
    valstat(idf) = str2num(stats{idf}(end-5:end-1));
end
res.gap(unfi_flt) = valstat;


%%
data = fun_table_values(qall_flt);
[~, ~, probids ] = unique(data(:,3:5), 'rows');
num_probs = max(probids);
%%
qcontid = 20;
qclipid = 16;
approxid = 5;
spid = 4;
covid = 1;
dsnum = [];
dpct = [];
dsnumqc = [];
dpctqc = [];
for idp = 1:num_probs
    pdata = data(probids==idp,:);
    flt_c = (pdata(:,13) == qcontid);
    flt_a = (pdata(:,13) == approxid);
    if any(flt_c) && any(flt_a)
        dsnum(end+1) = abs(pdata(flt_c, 11)-pdata(flt_a, 11));
        dpct(end+1) = pdata(flt_a, 11)/pdata(flt_c, 11);
    end
    
    flt_c = (pdata(:,13) == qclipid);
    flt_a = (pdata(:,13) == approxid);
    if any(flt_c) && any(flt_a)
        dsnumqc(end+1) = abs(pdata(flt_c, 11)-pdata(flt_a, 11));
        dpctqc(end+1) = pdata(flt_a, 11)/pdata(flt_c, 11);
    end
end