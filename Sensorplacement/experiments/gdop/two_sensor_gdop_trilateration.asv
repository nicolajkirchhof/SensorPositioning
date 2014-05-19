function two_sensor_gdop_trilateration
%%
outer = createCircle([0, 0], [10000,0]);
inner = createCircle([0, 0], [9000,0]);
outer_poly = circleToPolygon(outer, 3600);
inner_poly = circleToPolygon(inner,3600);

uc_poly = bpolyclip(int64(outer_poly'),int64(inner_poly'), 0);

%%%
% cla
% mb.drawPolygon(uc_poly)

%%%
% figure;
s1 = uc_poly;
steps = 0:100:19999;
s1s2_ang = zeros(size(steps));
pcut = cell(size(steps));
cnt = 0;
for step = steps
cnt = cnt+1;
%     fprintf('%f, %s', step, '\');
% end
% %%
% i = 10;
% step = 1000*i;
s2 = mb.polygonTranslate(uc_poly, [step 0]);
pcut{cnt} = bpolyclip(s1, s2, 1);
s1_ang = real(acos(step/(2*9500)));
s1s2_ang(cnt) = 2*(pi/2-s1_ang);
% mb.drawPolygon(pcut);
end

psize = zeros(size(pcut));
ipmax = zeros(size(pcut));
ipmean = zeros(size(pcut));
plength = zeros(size(pcut)); 
cnt = 1;
for cnt = 1:numel(pcut)-1
    %%
    psize(cnt) = mb.polygonArea(pcut{cnt});
    [dists, ipx] = mb.polygonInterpointDistances(pcut{cnt});
    ipmax(cnt) = max(dists);
    ipmean(cnt) = mean(dists);
    plength(cnt) = mb.polygonLength(pcut{cnt}); 
end

%%
% h_size = figure; 
figure;
subplot(2,2,1);
plot(s1s2_ang, psize./max(psize));
title('scaled size for two sensors');
ylim([0, 0.1])
xlim([0,pi]);

% h_1_sin = figure; 
subplot(2,2,2);
plot(s1s2_ang, 1./sin(s1s2_ang));
title('1/sin(\phi) for two sensors');
ylim([0,3]);
xlim([0,pi]);

% h_sin = figure; 
subplot(2,2,4);
plot(s1s2_ang, sin(s1s2_ang));
title('sin(\phi) for two sensors');
xlim([0,pi]);

% h_ipmax = figure;
% plot(s1s2_ang, ipmax);
% title('max interpoint distance for two sensors');
% xlim([0,pi]);

% h_ipmean = figure;
% plot(s1s2_ang, ipmean);
% title('mean interpoint disatance for two sensors');
% xlim([0,pi]);

% h_plength = figure;
subplot(2,2,3);
plot(s1s2_ang, plength./max(plength));
title('polygon lenght for two sensors');
xlim([0,pi]);
ylim([0,0.2]);

