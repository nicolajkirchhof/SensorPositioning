function two_sensor_gdop_trilateration
%%
outer = createCircle([0, 0], [10000,0]);
inner = createCircle([0, 0], [9000,0]);
outer_poly = circleToPolygon(outer, 3600);
inner_poly = circleToPolygon(inner,3600);

uc_poly = bpolyclip(int64(outer_poly'),int64(inner_poly'), 0);

%%%
cla
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
delete(gca)
% cla;
hold on;
% set(gca, 'ytick', []);
s1s2_ang_deg = rad2deg(s1s2_ang);
% scale_size = 30./max(psize);
scale_size = 0.5/1000^2;
plot(s1s2_ang_deg, scale_size*psize, 'color', 'k');
% scale_length = 30*0.5./max(plength);
scale_length = 0.125/1000;
plot(s1s2_ang_deg, scale_length*plength, 'color', 0.5*ones(1,3));
plot(s1s2_ang_deg, 1./sin(s1s2_ang), 'color', 0.7*ones(1,3));
legend('Length $[m/8]$', 'Area $[m^2/2]$', 'Sin$^{-1}$', 'Location', 'North');
% title('scaled size for two sensors');
ylim([0.5, 3.5]);
xlim([0, 180]);
ylabel('');
xlabel('Inner bearing angle $[^{\circ}]$');
%%
Figures.makeFigure('GdopTrilateration', [], '7cm');
% matlab2tikz('export/gdop_trilateration.tikz', 'parseStrings', false,... 
%     'tikzFileComment', '% -*- root: TestingFigures.tex -*-',...
%     'extraAxisOptions',{'y post scale=1'});

