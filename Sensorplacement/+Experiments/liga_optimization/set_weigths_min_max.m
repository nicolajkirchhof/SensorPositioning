%%
sw_min = set_weigths(1); 
sw_max = set_weigths(1); 
id_min = 1;
id_max = 1;
cnt = 1;
slice = nchoosek(40,10)/16;
while cnt <= 16
    sw = set_weigths((1:slice)+(slice*cnt));
    [tmin, idmin] = min(sw);
    if min(sw)<sw_min 
        sw_min = tmin;
        id_min = idmin+(slice*cnt);
    end
    [tmax, idmax] = max(sw);
    if tmax>sw_max
        sw_max = tmax;
        id_max = idmin+(slice*cnt);
    end
    cnt= cnt+1;
%     if mod(id, 10000)==0
        disp(cnt);
%     end
end