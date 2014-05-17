function two_sensor_gdop_trilateration
%%
outer = createCircle([0, 0], [10000,0]);
inner = createCircle([0, 0], [9000,0]);
outer_poly = circleToPolygon(outer, 3600);
inner_poly = circleToPolygon(inner,3600);

uc_poly = bpolyclip(int64(outer_poly'),int64(inner_poly'), 0);

%%
cla
mb.drawPolygon(uc_poly)

%%
% figure;
s1 = uc_poly;
steps = 0:1000:20000;
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
%%
psize = zeros(size(pcut));
cnt = 1;
for cnt = 1:numel(pcut)
    %%
    psize(cnt) = mb.polygonArea(pcut{cnt});
end

%%
h_size = figure; 
plot(s1s2_ang, psize./max(psize));
title('scaled size for two sensors');
ylim([0, 0.1])

h_1_sin = figure; 
plot(s1s2_ang, 1./sin(s1s2_ang));
title('1/sin(\phi) for two sensors');
ylim([0,3]);

h_sin = figure; 
plot(sin(s1s2_ang));
title('sin(\phi) for two sensors');

ylim([0, 6000000])
ylim([0, 3])