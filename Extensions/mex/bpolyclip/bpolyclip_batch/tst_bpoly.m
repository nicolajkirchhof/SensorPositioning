run ..\..\..\..\..\..\..\matlab\custom\matGeom-1.1.5_nico\matGeom\setupMatGeom.m
%%
p1 = {int64([0.0, 1.3; 2.4, 0.1; 2.1, 2.8; 1.4, 1.6; 0.0, 1.3]'*1000)};
p2 = {int64([0.0, 0.3; 2.4, 0; 3.4, 1.2; 2.8, 1.8; 0, 1.6; 0.0, 0.3]'*1000), int64([2.0, 1.0; 1.999, 0.999; 2.0, 0.6; 1.0, 0.5;2.0, 1.0 ]'*1000)};
%%
cla; hold on;
draw_polygon(p1, 'g');
draw_polygon(p2, 'r')
%%
[presult, a] = bpolyclip(p1, p2, 1);
pa = polygonArea(presult{1}{1}');
draw_multipolygon(presult, 'k')
%%
cross_check_polygons(p1, p2, [], [], true);
%%
cla; hold on;
p3 = {p1{1}*5};
p4 = {p1{1}*10};
mp1 = {{p1{1}*5}, {p2{1}*7, p2{2}*7}};
draw_multipolygon(mp1, 'k')
mp2 = {p3, p4};
draw_multipolygon(mp2, 'm')
presult = bpolyclip(mp1, mp2, 1);