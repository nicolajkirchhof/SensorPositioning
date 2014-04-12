function ucmb = uniquecmb(allcmb)

ucmb = unique(sort(allcmb,2),'rows');
% ucmb = unique(allcmb,'rows');