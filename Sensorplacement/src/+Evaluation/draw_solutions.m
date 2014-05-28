function draw_solutions(res)
% allowedtags = {'_coverage', '_sameplace' '_qclip' '_sc_backward' '_qcontinous_sub' 'sc_forward' 'sc_ind'};
%%
% filter
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

%%
figure;
hqual = gca;
hold on;
title('qualities')
figure;
htime = gca;
hold on;
title('times')
figure;
hsensor = gca;
hold on;
title('sensors')
% figure;
% hqual2 = gca;
% hold on;
% title('qualities')
% figure;
% htime2 = gca;
% hold on;
% title('times')
% figure;
% hsensor2 = gca;
% hold on;
% title('sensors')


function [h1 h3] = draw_sorted(flt, col, name, marker )

   prob_sz = log10(res.wp(flt).^2.*res.sp(flt));
%     prob_sz = log10(res.sc(flt).*res.sp(flt).*res.wp(flt).*res.ap(flt));
   qual_val = res.qual(flt)./res.wp(flt);
   time_val = res.total.sec(flt);
   sensor_val = res.numsensors(flt);
   [prob_sz_sort, prob_sz_idx] = sort(prob_sz);

    h1 = plot(hqual, prob_sz_sort, qual_val(prob_sz_idx), 'color',col, 'marker', marker, 'LineWidth', 1, 'markersize', 5);
    legend(h1, name);
    
    h2 = plot(htime, prob_sz_sort, time_val(prob_sz_idx), 'color', col, 'marker', marker, 'LineWidth', 1);
    legend(h2, name);
    h3 = plot(hsensor, prob_sz_sort, sensor_val(prob_sz_idx), 'color', col, 'marker', marker, 'LineWidth', 1, 'markersize', 5);
    legend(h3, name);
%     scatter(hqual2, res.wp(flt), res.sp(flt), 
end
col = repmat((0:10)', 1, 3)*0.1;
draw_sorted(cov_flt, col(1,:) , 'cov', 's');
draw_sorted(approx_flt, col(6,:), 'approx', 'o');
[h1 h3] = draw_sorted(sp_flt, col(1,:), 'sp', 's');
[h1 h3] = draw_sorted(qcont_flt, col(3,:), 'qcont', 'x');
% delete(h2);
[h1 h3] = draw_sorted(qclip_flt, col(3,:), 'qclip', '+');
% delete(h2);

return
%%
figure
%
cla, 
hold on;
ylim([50 500]);
flt = qcont_flt; 
[res.total.sec(flt).*(1./res.gap(flt))./(100)]./200
% colormap gray
scatter(res.wp(flt), res.sp(flt), res.total.sec(flt).*(1./res.gap(flt))./(100), 'MarkerEdgeColor', [0 0 0], 'LineWidth', 2);
scatter(res.wp(qclip_flt), res.sp(qclip_flt), res.total.sec(qclip_flt).*(1./res.gap(qclip_flt))./(100), 'MarkerEdgeColor', [1 1 1]*0.5,'LineWidth', 2);
% scatter(res.wp(flt), res.sp(flt), res.total.sec(flt)./(100), 'MarkerEdgeColor', [0 0 0], 'LineWidth', 2);
% scatter(res.wp(qclip_flt), res.sp(qclip_flt), res.total.sec(qclip_flt)./(100), 'MarkerEdgeColor', [1 1 1]*0.5,'LineWidth', 2);
%%
clc
flt = qcont_flt; 
vals = [res.gap(flt), res.wp(flt), res.sp(flt)]
fprintf('\\addplot[only marks,mark=x,mark size=%gpt,color=white!90!black] plot coordinates{\n(%d,%d)\n};\n', [(res.total.sec(flt).*(1./res.gap(flt))./(100))/200, res.wp(flt), res.sp(flt)]')
flt = qclip_flt; 
vals = [res.gap(flt), res.wp(flt), res.sp(flt)]

fprintf('\\addplot[only marks,mark=+,mark size=%gpt,color=white!50!black] plot coordinates{\n(%d,%d)\n};\n', [(res.total.sec(flt).*(1./res.gap(flt))./(100))/200, res.wp(flt), res.sp(flt)]')


%%
figure
%
col = repmat((0:10)', 1, 3)*0.1;
cla, 
hold on;
ylim([50 500]);
flt = qcont_flt; 
[100*res.qual(flt)./res.wp(flt)]/22
    
% colormap gray
h=scatter(res.wp(flt), res.sp(flt), 100*res.qual(flt)./res.wp(flt), 'MarkerEdgeColor', col(5,:), 'LineWidth', 1, 'Marker', 'x');
legend(h,'qopt');
flt = qclip_flt;
[100*res.qual(flt)./res.wp(flt)]/22
h=scatter(res.wp(flt), res.sp(flt), 100*res.qual(flt)./res.wp(flt), 'MarkerEdgeColor', col(5,:),'LineWidth', 1, 'Marker', '+');
legend(h,'qclip');
flt = approx_flt;
h=scatter(res.wp(flt), res.sp(flt), 100*res.qual(flt)./res.wp(flt), 'MarkerEdgeColor', col(3,:),'LineWidth', 1);
legend(h,'approx');
flt = cov_flt;
h=scatter(res.wp(flt), res.sp(flt), 100*res.qual(flt)./res.wp(flt), 'MarkerEdgeColor', col(3,:),'LineWidth', 1, 'Marker', 's');
legend(h,'qcont');

legend hide
%%
clc
flt = qcont_flt; 
fprintf('\\addplot[only marks,mark=x,mark size=%gpt,color=white!50!black] plot coordinates{\n(%d,%d)\n};\n', [[100*res.qual(flt)./res.wp(flt)]/30, res.wp(flt), res.sp(flt)]')
flt = qclip_flt; 
fprintf('\\addplot[only marks,mark=+,mark size=%gpt,color=white!50!black] plot coordinates{\n(%d,%d)\n};\n', [[100*res.qual(flt)./res.wp(flt)]/30, res.wp(flt), res.sp(flt)]')
flt = approx_flt;
fprintf('\\addplot[only marks,dashed,mark=o,mark size=%gpt,color=white!20!black] plot coordinates{\n(%d,%d)\n};\n', [[100*res.qual(flt)./res.wp(flt)]/30, res.wp(flt), res.sp(flt)]')
flt = cov_flt;
fprintf('\\addplot[only marks,mark=square,mark size=%gpt,color=white!20!black] plot coordinates{\n(%d,%d)\n};\n', [[100*res.qual(flt)./res.wp(flt)]/30, res.wp(flt), res.sp(flt)]')
% flt = cov_flt;
% scatter(res.wp(flt), res.sp(flt), 100*res.qual(flt)./res.wp(flt), 'MarkerEdgeColor', col(3,:),'LineWidth', 1, 'Marker', 's');
% legend(h,'cov');
% zoom(4);
%%
matlab2tikz('fig\solvingquality.tex')
%%

figure, 



return;
%%
cov_prob_sz = res.wp(cov_flt)+res.sp(cov_flt);
cov_qual_val = res.qual(cov_flt)./res.wp(cov_flt);
[cov_prob_sz_sort, cov_prob_sz_idx] = sort(cov_prob_sz);

plot(cov_prob_sz_sort, cov_qual_val(cov_prob_sz_idx), 'og')
%%
sp_prob_sz = res.wp(sp_flt)+res.sp(sp_flt);
sp_qual_val = res.qual(sp_flt)./res.wp(sp_flt);
[sp_prob_sz_sort, sp_prob_sz_idx] = sort(sp_prob_sz);

plot(sp_prob_sz_sort, sp_qual_val(sp_prob_sz_idx), 'ob')

%%
approx_prob_sz = res.wp(approx_flt)+res.sp(approx_flt);
approx_qual_val = res.qual(approx_flt)./res.wp(approx_flt);
[approx_prob_sz_sort, approx_prob_sz_idx] = sort(approx_prob_sz);

plot(approx_prob_sz_sort, approx_qual_val(approx_prob_sz_idx), 'ok')

%%
qcont_prob_sz = res.wp(qcont_flt)+res.sp(qcont_flt);
qcont_qual_val = res.qual(qcont_flt)./res.wp(qcont_flt);
[qcont_prob_sz_sort, qcont_prob_sz_idx] = sort(qcont_prob_sz);

plot(qcont_prob_sz_sort, qcont_qual_val(qcont_prob_sz_idx), 'ok')

end