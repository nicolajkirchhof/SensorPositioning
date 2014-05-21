function triangulation_gdop_to_polygon_parameter_fitting

flti = 40:320; fltj = 1:9; psizeflt = psize(flti, fltj); qkellyflt = qkelly(flti, fltj);
% figure, hold on, plot(psizeflt), plot(qkellyflt)
fun_pdiffflt = @(x) psizeflt-x.*qkellyflt;
offset = fminsearch(@(x) sum(sum(fun_pdiffflt(x).^2)), 1);
pdiffflt = fun_pdiffflt(offset);
% figure, plot(pdiffflt);


%%

flti = 120:240; fltj = 1:9; pipmxflt = pinterpointmax(flti, fltj); qkellyflt2 = qkelly(flti, fltj);
figure, hold on, plot(pipmxflt), plot(qkellyflt2)
fun_pdiffflt2 = @(x) pipmxflt-x.*qkellyflt2;
offset2 = fminsearch(@(x) sum(sum(fun_pdiffflt2(x).^2)), 1);
pdiffflt2 = fun_pdiffflt2(offset2);
% figure, plot(pdiffflt2);
figure,hold on; plot(angs(flti,1), pipmxflt), plot(angs(flti,1), offset2.*qkellyflt2); 

%%
figure,
sz = {2,2};
plt = 1;
subplot(sz{:}, plt)
plot(angs(:,1), psize); hold on;
plot(angs(:,1), offset.*qkelly)
line([0, 180], [pszline pszline], 'color', markercolor);
ylim([0 2]);
title('polygon size vs fitted qkelly for different angs and distances');

plt = plt+1;
subplot(sz{:}, plt);
plot(angs(:,1), psize-offset.*qkelly); hold on;
% plot(angs(:,1), offset.*qkelly)
% line([0, 180], [pszline pszline], 'color', markercolor);
ylim([-2 2]);
title('diff polygon size vs fitted qkelly for different angs and distances');

% figure,
% sz = {1,2};
% plt = 1;
plt = plt+1;
subplot(sz{:}, plt)
plot(angs(:,1), pinterpointmax(:, 1:2:end)); hold on;
plot(angs(:,1), offset2.*qkelly(:,1:2:end))
line([0, 180], [pimxline pimxline], 'color', markercolor);
ylim([0 5]);
title('polygon size vs fitted qkelly for different angs and distances');

plt = plt+1;
subplot(sz{:}, plt);
plot(angs(:,1), pinterpointmax-offset2.*qkelly); hold on;
% plot(angs(:,1), offset.*qkelly)
% line([0, 180], [pszline pszline], 'color', markercolor);
ylim([-5 5]);
title('diff polygon size vs fitted qkelly for different angs and distances');
